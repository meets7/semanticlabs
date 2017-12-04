package lab2 ;

import java.io.FileWriter;
import java.io.IOException;

import org.apache.jena.query.Dataset;
import org.apache.jena.rdf.model.*;
import org.apache.jena.tdb.TDBFactory;
import org.apache.jena.vocabulary.*;

public class Lab_2 extends Object {
    
      public static void main (String args[]) throws IOException {
    	  
    	  	//Remove log warning
    	  	org.apache.log4j.Logger.getRootLogger().setLevel(org.apache.log4j.Level.OFF);
    	  	// namespace definitions
  		String mainNamespace     = "http://utdallas/fall17#";
  		String baseUri    = "http://utdallas/fall17";
  		String movieNamespace   = baseUri + "/movie#";
  		String personNamespace  = baseUri + "/person#";
  		String bookNamespace    = baseUri + "/book#";
  		
  		
  		//Define Data
  		//People
  		String kubrickURI    = personNamespace + "StanleyKubrick";
  		String kubrickGiven  = "Stanley";
  		String kubrickFamily = "Kubrick";
  		
  		String peterGeorgeURI   = personNamespace + "peterGeorge";		
  		String peterGeorgeGiven  = "Peter";
  		String peterGeorgeLast = "George";	
  		
  		String anthonyBurgessURI = personNamespace + "anthonyBurgess";
  		String anthonyBurgessGiven = "Anthony";
  		String anthonyBurgessLast = "Burgess";
  		
  		
  		//Movies
  		String clockworkURI   = movieNamespace + "clockworkOrange";
  		String clockworkTitle = "A Clockwork Orange";
  		String clockworkYear  = "1971";
  		String clockworkGenre = "Crime, Drama, Sci-Fi";
  		
  		String strangeloveURI   = movieNamespace + "drStrangelove";
  		String strangeloveTitle = "Dr. Strangelove or: How I Learned to Stop Worrying and Love the Bomb";
  		String strangeloveYear  = "1964";
  		String strangeloveGenre = "Comedy";
  		
  		//Books
  		String redAlertURI    = bookNamespace + "redAlert";
  		String redAlertTitle  = "Red Alert";
  		String redAlertYear   = "1958";
  		String redAlertLanguage = "en";
  		String redAlertISBN = "ISBN:9781596545816";
  		
  		String aClockWorkOrangeBookURI    = bookNamespace + "aclockworkorange";
  		String aClockWorkOrangeBookTitle  = "A ClockWork Orange";
  		String aClockWorkOrangeBookYear   = "1962";	
  		String aClockWorkOrangeBookLanguage = "en";
  		String aClockWorkOrangeBookISBN = "ISBN:0434098000";
        
  		//End of data definitions

        // create an empty model
        String directory = "MyDatabases/Dataset1" ;
        Dataset dataset = TDBFactory.createDataset(directory) ; 
        Model model = dataset.getDefaultModel();
        
		model.setNsPrefix("default", mainNamespace);		
		model.setNsPrefix("movie", movieNamespace);
		model.setNsPrefix("person", personNamespace);
		model.setNsPrefix("book", bookNamespace);
		
		Property movieGenre    = model.createProperty(movieNamespace, "genre");
		Property movieDirector = model.createProperty(movieNamespace, "directedby");
		Property basedOn  = model.createProperty(movieNamespace, "basedOn");

        // create the resources
		Resource movie  = model.createResource(movieNamespace);
		Resource book   = model.createResource(bookNamespace);

		// People Resources
		Resource stanleyKubrick = model.createResource(kubrickURI);
		stanleyKubrick.addProperty(VCARD.FN, kubrickGiven + kubrickFamily)
					  .addProperty(VCARD.Given, kubrickGiven)
					  .addProperty(VCARD.Family, kubrickFamily);
		
		Resource peterGeorge = model.createResource(peterGeorgeURI);
		peterGeorge.addProperty(VCARD.FN, peterGeorgeGiven + peterGeorgeLast)
					  .addProperty(VCARD.Given, peterGeorgeGiven)
					  .addProperty(VCARD.Family, peterGeorgeLast);
		
		Resource anthonyBurgess = model.createResource(anthonyBurgessURI);
		anthonyBurgess.addProperty(VCARD.FN, anthonyBurgessGiven + anthonyBurgessLast)
					  .addProperty(VCARD.Given, anthonyBurgessGiven)
					  .addProperty(VCARD.Family, anthonyBurgessLast);
		
		//Book Resources
		Resource redAlert = model.createResource(redAlertURI);
		redAlert.addProperty(RDF.type, book)
				.addProperty(DC.creator, peterGeorge)
				.addProperty(DC.title, redAlertTitle)
				.addProperty(DC.date, redAlertYear)
				.addProperty(DC.language, redAlertLanguage)
				.addProperty(DC.identifier, redAlertISBN);
		
		Resource aclockworkorangebook = model.createResource(aClockWorkOrangeBookURI);
		aclockworkorangebook.addProperty(RDF.type, book)
						    .addProperty(DC.creator, anthonyBurgess)
						    .addProperty(DC.title, aClockWorkOrangeBookTitle)
						    .addProperty(DC.date, aClockWorkOrangeBookYear)
						    .addProperty(DC.language, aClockWorkOrangeBookLanguage)
						    .addProperty(DC.identifier, aClockWorkOrangeBookISBN);
		
		//Movie Resources
		
		Resource drStrangelove = model.createResource(strangeloveURI);
		drStrangelove.addProperty(RDF.type, movie)
					 .addProperty(DC.title, strangeloveTitle)
					 .addProperty(DC.date, strangeloveYear)
					 .addProperty(movieGenre, strangeloveGenre)	
					 .addProperty(movieDirector, stanleyKubrick)
					 .addProperty(basedOn, redAlert);
		
		Resource clockworkOrange = model.createResource(clockworkURI);
		clockworkOrange.addProperty(RDF.type, movie)
					   .addProperty(DC.title, clockworkTitle)
					   .addProperty(DC.date, clockworkYear)
					   .addProperty(movieGenre, clockworkGenre)
					   .addProperty(movieDirector, stanleyKubrick)
					   .addProperty(basedOn, aclockworkorangebook);
		
		FileWriter WriteAsXML = new FileWriter("LAB2_3_DSangvikar.xml");
		FileWriter WriteAsN3 = new FileWriter("LAB2_3_DSangvikar.n3");
		model.write(WriteAsXML, "RDF/XML");
		model.write(WriteAsN3, "N3");
		
		model.close();
		dataset.close();
      }
}
