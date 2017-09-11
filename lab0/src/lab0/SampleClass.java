package lab0;

import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;

public class SampleClass {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
	    try {
			PrintWriter writer = new PrintWriter("myfile.txt", "UTF-8");
			writer.println("The first line");
			writer.close();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
