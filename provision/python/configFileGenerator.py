import xml.etree.ElementTree as ET
import xml.dom.minidom as minidom
import sys, getopt
import os
import shutil

defdict = dict()
cwd = os.getcwd()
#Adds xml version and reference to the stylesheet. Makes it easier to read in xml readers.
def insertStylesheet(fileName):
    with open(fileName, "r") as f3:
        lines = f3.readlines()
    lines.insert(0, '<?xml version="1.0"?>\n<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>\n')
    with open(fileName, "w") as f4:
        for line in lines:
            f4.write(line)

#Reads the default xml files from Apache. Update files when Hadoop version updates.
#Keep files in same directory as script.
def readDefs():
    
    tree = ET.parse("yarn-site.xml")
    for elem in tree.iter():
        if elem.tag == "name":
            defdict[elem.text] = "yarn-site.xml"
        
    tree = ET.parse("core-site.xml")
    for elem in tree.iter():
        if elem.tag == "name":
            defdict[elem.text] = "core-site.xml"
    
    tree = ET.parse("hdfs-site.xml")
    for elem in tree.iter():
        if elem.tag == "name":
            defdict[elem.text] = "hdfs-site.xml"
    
    tree = ET.parse("mapred-site.xml")
    for elem in tree.iter():
        if elem.tag == "name":
            defdict[elem.text] = "mapred-site.xml"

#Creates a new set of xml config files for hadoop.
def initialConfig(HadoopConf):
    print("Initial Config")
    fileName = ""
    path_to_defaults = cwd + "/defaults/"
    path_to_config = cwd + "/config/"
    print(path_to_defaults)
    infile = path_to_config + HadoopConf
    
    #Use the default property files as base to create the modified files.
    shutil.copy2(path_to_defaults + "core-default.xml", "core-site.xml")
    shutil.copy2(path_to_defaults + "hdfs-default.xml", "hdfs-site.xml")
    shutil.copy2(path_to_defaults + "mapred-default.xml", "mapred-site.xml")
    shutil.copy2(path_to_defaults + "yarn-default.xml", "yarn-site.xml")
    
    readDefs()


    #This loop needs to be optimized.
    with open(infile) as f:
        for line in f:
            properties = line.split("::")
            fileName = defdict[properties[0]]
            tree = ET.parse(fileName)
            for elem in tree.iter():
                if elem.tag == "property" and elem[0].text == properties[0]:
                    elem[1].text = properties[1].rstrip()
            tree.write(fileName) #Files get written every loop.
            insertStylesheet(fileName) #Files get written again.

#Changes the value of one property.
def singleConfig(hadoopProp):
    readDefs()
    properties = hadoopProp.split("::")
    fileName = defdict[properties[0]]
    
    tree = ET.parse(fileName)

    for elem in tree.iter():
        if elem.tag == "property" and elem[0].text == properties[0]:
            elem[1].text = properties[1].rstrip()
    
    tree.write(fileName)
    insertStylesheet(fileName)

def main(argv):
   inputfile = ''
   outputfile = ''
   print("Full path " + cwd)
   try:
      opts, args = getopt.getopt(argv,"hi:s:",["iconfig=","sconfig="])
   except getopt.GetoptError:
      print('configFileGenerator.py -i <config file name> -s <propertyname::propertyvalue>')
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print('configFileGenerator.py -i <config file name> -s <propertyname::propertyvalue>')
         sys.exit()
      elif opt in ("-i", "--iconfig"):
         initialConfig(arg)
      elif opt in ("-s", "--sconfig"):
         singleConfig(arg)

if __name__ == "__main__":
   main(sys.argv[1:])
