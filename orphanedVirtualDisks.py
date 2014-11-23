import xml.etree.ElementTree as ET
import subprocess
import os


############################## GET USED IMAGE LIST #############################
# This function dumps the XML for all defined virsh guest systems and parses   #
# the XML to get the list of virtual disks they each use. An aggrigate list    #
# of all the virual disks' absolute paths are returned                         #
################################################################################
def getUsedImageList():

    # Get the list of all defined guests
    listDomainsProcess = subprocess.Popen(['virsh', 'list', '--all', '--name'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = listDomainsProcess.communicate()
    if err != "":
        print "There was an error with the printing"
        print err
        exit()

    diskImageNames = []
    for line in out.split('\n'):
        # if the line only contains whitespace skip it
        if line.strip() == "":
            continue

        dumpXMLProcess = subprocess.Popen(['virsh', 'dumpxml', line.strip()], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = dumpXMLProcess.communicate()
        if err != "":
            print "There was an error with the printing"
            print err
            continue

        # Set the XML to the output of the function
        xml = out

        # Import the XML document
        root = ET.fromstring(xml)

        # Build the tree to match the XML document against
        matchTree = [
            {
                'tag': 'devices',
                'attrib': {},
            },
            {
                'tag': 'disk',
                'attrib': {'type': 'file', 'device': 'disk'},
            },
            {
                'tag': 'source',
                'attrib': {},
            }
        ]

        # checks if the subset is within the superset (if the subset is a subset of the superset)
        def isSubset(superset, subset):
            for key in subset.keys():

                # If the value does not exists in the superset return false
                if key not in superset:
                    return False

                # If the values do not equal each other return false
                if subset[key] != superset[key]:
                    return False

            return True

        # recusive function to find all of the children that match the predefined pattern
        def findChildren(parentXML, matchTree):

            # Base case, retun an array of just the XML element
            if len(matchTree) == 0:
                return [parentXML]

            tag = matchTree[0]['tag']
            attrib = matchTree[0]['attrib']

            matches = []

            for childXML in parentXML:

                # if this child node has the right tag and contains the right attributes
                if childXML.tag == tag and isSubset(superset=childXML.attrib, subset=attrib):
                    # Recurse with the child and the next element of the matchTree
                    matches.extend(findChildren(childXML, matchTree[1:]))

            return matches

        for child in findChildren(root, matchTree):
            diskImageNames.append(child.attrib['file'])

    return diskImageNames


################################ GET IMAGES LIST ###############################
# This function gets all the files with the extention `.img` in the given      #
# path and retuns their filename appended to the directory path that was given #
################################################################################
def getImagesList(directory):
    imageFiles = []
    for filename in os.listdir(directory):
        if filename.endswith(".img"):

            fullpath = os.path.join(directory, filename)

            imageFiles.append(fullpath)

    return imageFiles

# Get disks that exist as files but dont exists in images
usedImageList = getUsedImageList()
for filename in getImagesList("/mnt/virtual_machines/"):
    if filename not in usedImageList:
        print filename
