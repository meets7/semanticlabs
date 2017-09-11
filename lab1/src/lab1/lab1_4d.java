
package lab1 ;

import java.io.FileWriter;
import java.io.IOException;

import org.apache.jena.query.Dataset;
import org.apache.jena.query.ReadWrite;
import org.apache.jena.rdf.model.*;
import org.apache.jena.tdb.TDBFactory;
import org.apache.jena.util.FileManager;
import org.apache.jena.vocabulary.*;


/** Tutorial 3 Statement attribute accessor methods
 */
public class lab1_4d extends Object {
    public static void main (String args[]) throws IOException {
	    	
    		//remove log4j warning
    		org.apache.log4j.Logger.getRootLogger().setLevel(org.apache.log4j.Level.OFF);
        // define data
        String personURI    = "http://utdallas.edu/fall17/TimBernersLee";
        String givenName    = "Timothy";
        String familyName = "Berners-Lee";
        String fullName     = "Sir " + givenName + " John " + familyName;
        String email = "timbl@w3.org";
        String birthdate = "June 8, 1955";
        String occupation = "Computer Scientist";
        // create dataset
        String directory = "MyDatabases/Dataset1" ;
        Dataset dataset = TDBFactory.createDataset(directory) ; 
        // create an empty model
        // Model model = dataset.getDefaultModel() ;
        Model mymodel = dataset.getNamedModel("myrdf") ;
        dataset.begin(ReadWrite.WRITE) ;
        Resource timbernerslee 
          = mymodel.createResource(personURI)
                 .addProperty(VCARD.FN, fullName)
                 .addProperty(VCARD.N, 
                		 mymodel.createResource()
                                   .addProperty(VCARD.Given, givenName)
                                   .addProperty(VCARD.Family, familyName))
                 .addProperty(VCARD.EMAIL, email)
                 .addProperty(VCARD.BDAY, birthdate)
                 .addProperty(VCARD.ROLE, occupation);
        
       String inputFileName = "dhruv_FOAFFriends.rdf";
       FileManager.get().readModel(mymodel, inputFileName);
       dataset.commit();
       
     // Print to file
	FileWriter WriteAsXML = new FileWriter("LAB1_4_DSangvikar.xml");
	FileWriter WriteAsNTP= new FileWriter("LAB1_4_DSangvikar.ntp");
	FileWriter WriteAsN3 = new FileWriter("LAB1_4_DSangvikar.n3");
	mymodel.write(WriteAsXML, "RDF/XML");
	mymodel.write(WriteAsNTP, "N-TRIPLE");
	mymodel.write(WriteAsN3, "N3");
	dataset.end();
    }
}
