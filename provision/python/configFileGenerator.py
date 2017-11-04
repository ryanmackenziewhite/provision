import xml.etree.ElementTree as ET
import xml.dom.minidom as minidom
import sys, getopt
import os

defdict = dict()

def insertStylesheet(fileName):
    with open(fileName, "r") as f3:
        lines = f3.readlines()
    lines.insert(1, '<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>\n')
    with open(fileName, "w") as f4:
        for line in lines:
            f4.write(line)

def readDefs():
    with open("definitions.ini") as f:
        for line in f:
            properties = line.split("::")
            defdict[properties[0]] = properties[1].rstrip()

def initialConfig():
    fileName = ""

    with open("config.ini") as f:
        for line in f:
            if ".xml" in line:
                fileName = line.rstrip()
                root = ET.Element("configuration")
            else:
                properties = line.split("::")
                xmlProperty = ET.SubElement(root, "property")
                xmlName = ET.SubElement(xmlProperty,"name")
                xmlName.text = properties[0].rstrip()
                xmlValue = ET.SubElement(xmlProperty, "value")
                xmlValue.text = properties[1].rstrip()
            xmlstr = minidom.parseString(ET.tostring(root)).toprettyxml(indent="    ")
            with open(fileName, "w") as f2:
                f2.write(xmlstr)
            insertStylesheet(fileName)

def singleConfig(hadoopProp):
    readDefs()
    properties = hadoopProp.split("::")
    fileName = defdict[properties[0]]
    
    tree = ET.parse(fileName)
    
    cproperties = tree.getroot().getchildren()

    for myprop in cproperties:
        if myprop[0].text == properties[0]:
            myprop[1].text = properties[1].rstrip()

    tree.write(fileName)
    with open(fileName, "r") as f3:
        lines = f3.readlines()
    lines.insert(0, '<?xml version="1.0" ?>\n')
    with open(fileName, "w") as f4:
        for line in lines:
            f4.write(line)
    insertStylesheet(fileName)

def main(argv):
   inputfile = ''
   outputfile = ''
   try:
      opts, args = getopt.getopt(argv,"hi:s:",["iconfig=","sconfig="])
   except getopt.GetoptError:
      print('configFileGenerator.py -i <iconfig> -s <sconfig>')
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print('configFileGenerator.py -i <iconfig> -s <sconfig>')
         sys.exit()
      elif opt in ("-i", "--iconfig"):
         initialConfig()
      elif opt in ("-s", "--sconfig"):
         singleConfig(arg)

if __name__ == "__main__":
   main(sys.argv[1:])