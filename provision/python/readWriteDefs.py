import xml.etree.ElementTree as ET

with open("configSlave.ini", "a") as f:
    tree = ET.parse("yarn-site.xml")
    for elem in tree.iter():
        if elem.tag == "property":
            f.write(elem[0].text + "::" + elem[1].text + "\n")
        
    tree = ET.parse("core-site.xml")
    for elem in tree.iter():
        if elem.tag == "property":
            f.write(elem[0].text + "::" + elem[1].text + "\n")
    
    tree = ET.parse("hdfs-site.xml")
    for elem in tree.iter():
        if elem.tag == "property":
            f.write(elem[0].text + "::" + elem[1].text + "\n")
    
    tree = ET.parse("mapred-site.xml")
    for elem in tree.iter():
        if elem.tag == "property":
            f.write(elem[0].text + "::" + elem[1].text + "\n")