import xml.etree.ElementTree as ET
import xml.dom.minidom as minidom
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
        with open(fileName, "r") as f3:
            lines = f3.readlines()
        lines.insert(1, '<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>\n')
        with open(fileName, "w") as f4:
            for line in lines:
                f4.write(line)