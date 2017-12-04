
package lab6 ;

import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.jena.query.Query;
import org.apache.jena.query.QueryExecution;
import org.apache.jena.query.QueryExecutionFactory;
import org.apache.jena.query.QueryFactory;
import org.apache.jena.query.QuerySolution;
import org.apache.jena.query.ResultSet;
import org.apache.jena.query.ResultSetFactory;
import org.apache.jena.query.ResultSetFormatter;
import org.apache.jena.rdf.model.*;
import org.apache.jena.reasoner.Reasoner;
import org.apache.jena.reasoner.rulesys.GenericRuleReasoner;
import org.apache.jena.reasoner.rulesys.Rule;
import org.apache.jena.vocabulary.DC;
import org.apache.jena.vocabulary.OWL;


public class lab6_1 extends Object {
    public static void main (String args[]) throws IOException {
      
      org.apache.log4j.Logger.getRootLogger().setLevel(org.apache.log4j.Level.OFF);
      System.out.println("Part b. Loading datasets.");
      Model model = ModelFactory.createDefaultModel() ;
      model.read("eswc-2008-complete_modified.rdf") ;
      model.read("eswc-2009-complete_modified.rdf") ;
      System.out.println("Done.");
      
      String sparqlQuery =  
      "prefix foaf: <http://xmlns.com/foaf/0.1/>"+
      "select ?Person08 ?Person09 ?personName ?paperTitle where"+
      " {"+
      " ?Person08  <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> foaf:Person."+
      " ?Person08 foaf:mbox_sha1sum ?mbox."+
      " ?Person08 foaf:name ?personName."+
      " ?Person09 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> foaf:Person."+
      " ?Person09 foaf:mbox_sha1sum ?mbox."+
      " {?Person08 foaf:made ?pprName."+
      " ?pprName <http://purl.org/dc/elements/1.1/title> ?paperTitle.}"+
      " union "+
      " {?Person09 foaf:made ?pprName."+
      " ?pprName <http://purl.org/dc/elements/1.1/title> ?paperTitle.}"+
      " filter ( regex(str(?Person08), \"http://data.semanticweb.org/person2008\")). "+
      " filter ( regex(str(?Person09), \"http://data.semanticweb.org/person2009\")) "+
      " } order by ?personName";
      Query query = QueryFactory.create(sparqlQuery);
      QueryExecution queryexectutor = QueryExecutionFactory.create(query, model);
      ResultSet queryresults = queryexectutor.execSelect();
    		ResultSet results =  ResultSetFactory.copyResults(queryresults);	// the result set returns an in-memory copy.
    		List <QuerySolution> formattedResults = ResultSetFormatter.toList(results);
    		System.out.println("Part c.");
    		ResultSetFormatter.out(System.out, results, query);
    		System.out.println("Done.");
    		System.out.println("End of First Listing.");
    		
    		System.out.println("Part d.\n");
          Property propertySamePerson = ResourceFactory.createProperty("http://utdallas.semclass/samePerson");
          List<Resource> people = new ArrayList<Resource>();
          for(int i = 0; i < formattedResults.size(); i++)
          {
             QuerySolution binding = formattedResults.get(i);
             Resource person08 = (Resource) binding.get("Person08");
             Resource person09 = (Resource) binding.get("Person09");
             model.add(person08, OWL.sameAs, person09);     
             model.add(person09, propertySamePerson, person08); 
			model.add(person08, DC.creator, "Dhruv Sangvikar"); //reification
			model.add(person09, DC.creator, "Dhruv Sangvikar"); //reification
          
			if(people.contains(person09) == false)
				people.add(person09);
		}
		System.out.println("Done.");
		
		System.out.println("Part e.");
		for(int i = 0; i < people.size();i++){
			String Person08 = String.format("<%s>", people.get(i).getNameSpace() + people.get(i).getLocalName());
			
			sparqlQuery =
           "prefix foaf: <http://xmlns.com/foaf/0.1/>"+
           "select ?personName ?paperName where{ "+
           Person08+"  <http://utdallas.semclass/samePerson> ?obj. "+
           Person08+"  foaf:name ?personName. { "+
           Person08+"  foaf:made ?pprName. "+
           " ?pprName <http://purl.org/dc/elements/1.1/title> ?paperName.}"+
           " union "+
           " {?obj foaf:made ?pprName."+
           " ?pprName <http://purl.org/dc/elements/1.1/title> ?paperName.}"+
           " } order by ?personName";
           query = QueryFactory.create(sparqlQuery);
           queryexectutor = QueryExecutionFactory.create(query, model);
           queryresults = queryexectutor.execSelect();
			results = ResultSetFactory.copyResults(queryresults); // the result set returns an in-memory copy.
			ResultSetFormatter.out(System.out, results, query);
		}
		System.out.println("Done.");
		System.out.println("End of Second Listing\n");
		
		System.out.println("Part f.");
		StringBuilder sb = new StringBuilder();
		sb.append("[owlsam:  (?x ?p ?y), (?x owl:sameAs ?z) -> (?z ?p ?y)] ");
       sb.append("[owlsam2: (?x owl:sameAs ?y) -> (?y owl:sameAs ?x)]");

           List<Rule> rules = new ArrayList<Rule>();
           rules.add(Rule.parseRule(sb.toString()));
           Reasoner reasoner = new GenericRuleReasoner(rules);
           InfModel infModel = ModelFactory.createInfModel(reasoner, model);

           for(int i = 0; i < people.size();i++){
             String Person08 = String.format("<%s>", people.get(i).getNameSpace() + people.get(i).getLocalName());
             sparqlQuery = 
					"prefix foaf: <http://xmlns.com/foaf/0.1/>"+
					"select ?personName ?paperName  where{ "+
					Person08+"  foaf:made ?pprName. "+
					Person08+"  foaf:name ?personName. "+
					" ?pprName <http://purl.org/dc/elements/1.1/title> ?paperName. }"
					+ " order by ?personName";
                 query = QueryFactory.create(sparqlQuery);
                 queryexectutor = QueryExecutionFactory.create(query, infModel);
                 results =  ResultSetFactory.copyResults(queryexectutor.execSelect());
                 ResultSetFormatter.out(System.out, results, query);
                 
             }
             System.out.println("Done.\n");
              System.out.println("End of Third Listing\n");
              
              System.out.println("Part g.\n");
              System.out.println("Printing results to N3 file format...");
              FileWriter fWrite = new FileWriter("Lab6_DSangvikar.N3");
              infModel.write(fWrite,"N3");
              System.out.println("Done.");
              System.out.println("---------------------------------------------------------------------------------------");
              System.out.println("End. It has been a fun experience doing these semantic lab assignments. Thank you!");
              System.out.println("---------------------------------------------------------------------------------------");
          }
      }
