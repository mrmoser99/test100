public with sharing class GARDStructureReader {
    

    // Create a class Book for processing
    public class Structure {
       
       List<MasterAssetType> MasterAssetTypes;
       
    }

	public class MasterAssetType {
		public string code;
		public string name;
		public boolean active;
	}
	
    public MasterAssetType[] parseStructure(XmlStreamReader reader) {
        MasterAssetType[] MasterAssetTypes = new MasterAssetType[0];
        boolean isSafeToGetNextXmlElement = true;
        while(isSafeToGetNextXmlElement) {
            // Start at the beginning of the book and make sure that it is a book
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
            	system.debug('reader:' + ' ' + reader.getLocalName());
                if ('MasterAssetType' == reader.getLocalName()) {
                	System.debug('special: ' + reader.getAttributeValue(null, 'Code'));
        			System.debug('special: ' + reader.getAttributeValue(null, 'Name'));
        			System.debug('special: ' + reader.getAttributeValue(null, 'Active'));
                    // Pass the book to the parseBook method (below) 
                    MasterAssetType mat = parseMasterAssetType(reader);
                    system.debug('done reading masterasset type: ' + mat);
                    MasterAssetTypes.add(mat);
                }
            }
            // Always use hasNext() before calling next() to confirm 
            // that we have not reached the end of the stream
            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break; 
            }
        }
        return MasterAssetTypes;
    }

    // Parse through the XML, determine the author and the characters
    MasterAssetType parseMasterAssetType(XmlStreamReader reader) {
        MasterAssetType mat = new MasterAssetType();
       
        boolean isSafeToGetNextXmlElement = true;
      
        String currentAttribute = '';
        
        while(isSafeToGetNextXmlElement) {
        	
        	if (reader.getEventType() == XmlTag.START_ELEMENT) {
        	 	currentAttribute = reader.getLocalName();
        	 	system.debug('reader local:' + reader.getLocalName());
        	 	
        	}
        	
        	if (reader.getEventType() == XmlTag.END_ELEMENT) {
                if ('MasterAssetType' == reader.getLocalName()) {
                	break;
                }
            } else if (reader.getEventType() == XmlTag.CHARACTERS) {
                string value = reader.getText();
                if (currentAttribute == 'Code')
                	mat.code = value;
                else
                if (currentAttribute == 'Name')
                	mat.name = value;
                else
                if (currentAttribute == 'Active')
                	mat.active = boolean.valueOf(value);
            }
           
            // Always use hasNext() before calling next() to confirm 
            // that we have not reached the end of the stream
            if (reader.hasNext()) {
            	system.debug('getting next');
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        return mat;
    }
}