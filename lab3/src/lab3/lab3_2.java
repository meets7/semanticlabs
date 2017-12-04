
package lab3 ;

import java.io.FileOutputStream;
import java.io.IOException;
import java.util.concurrent.TimeUnit;

import org.apache.jena.ext.com.google.common.base.Stopwatch;
import org.apache.jena.query.Query;
import org.apache.jena.query.QueryExecution;
import org.apache.jena.query.QueryExecutionFactory;
import org.apache.jena.query.QueryFactory;
import org.apache.jena.query.ResultSet;
import org.apache.jena.query.ResultSetFormatter;
import org.apache.jena.rdf.model.*;


public class lab3_2 extends Object {
    public static void main (String args[]) throws IOException {
	    	
    		org.apache.log4j.Logger.getRootLogger().setLevel(org.apache.log4j.Level.OFF);
    		Model model = ModelFactory.createDefaultModel() ;
    		Stopwatch stopwatch = Stopwatch.createStarted();
    		model.read("Monterey.rdf") ;
    		stopwatch.stop();
    		long millis = stopwatch.elapsed(TimeUnit.MILLISECONDS);
    		System.out.printf("Time to load Monterey.rdf: %d milliseconds \n", millis);
    		String sparqlQuery = "SELECT ?p ?o\n" + 
    				"WHERE { <http://urn.monterey.org/incidents#incident1> ?p ?o }";
    		Query query = QueryFactory.create(sparqlQuery);
    		QueryExecution queryexectutor = QueryExecutionFactory.create(query, model);
    		ResultSet results = queryexectutor.execSelect();
    		System.out.printf("Printing output to file...\n");
    		FileOutputStream fOut = new FileOutputStream("Lab3_2_DSangvikar.xml");
    		ResultSetFormatter.outputAsXML(fOut, results, null);
    		fOut.close();
    		queryexectutor.close();
    		System.out.printf("Done.\n");
    }
}
