import xml.etree.ElementTree as ET

with open("definitions.ini", "a") as f:
    tree = ET.parse("yarn-default.xml")
    for elem in tree.iter():
        if elem.tag == "name":
            f.write(elem.text + "::yarn-site.xml" + "\n")
        
    tree = ET.parse("core-default.xml")
    for elem in tree.iter():
        if elem.tag == "name":
            f.write(elem.text + "::core-site.xml" + "\n")
    
    tree = ET.parse("hdfs-default.xml")
    for elem in tree.iter():
        if elem.tag == "name":
            f.write(elem.text + "::hdfs-site.xml" + "\n")
    
    tree = ET.parse("mapred-default.xml")
    for elem in tree.iter():
        if elem.tag == "name":
            f.write(elem.text + "::mapred-site.xml" + "\n")