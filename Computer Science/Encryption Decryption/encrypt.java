import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.Scanner;


public class encrypt {
	public static void main (String [] args) throws IOException  {
		encrypt();
	}
	
	public static void encrypt() throws IOException {		
		
		Scanner input = new Scanner(System.in);		
		
		System.out.println("enter the name of file to encrypt");
		String inputFilename = input.next();		
		PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(inputFilename+".encrypted", true)));
		
		System.out.println("Enter the key byte the range of -128 to 127"); 
		byte key = (byte) input.nextInt();		
		
    	FileInputStream fileInputStream=null;    	 
        File file = new File(inputFilename); 
        byte[] bFile = new byte[(int) file.length()];
        byte a;
        try {
            //convert file into array of bytes
	    fileInputStream = new FileInputStream(file);
	    fileInputStream.read(bFile);
	    fileInputStream.close();
 
	    for (int i = 0; i < bFile.length; i++) {
	       	System.out.print((char)bFile[i]);
            }
	    System.out.println("\n");
	    for (int i = 0; i < bFile.length; i++) {
	    	a = (byte)(bFile[i] + key);
	    	out.print((char)a);
	    	System.out.println((char)a);
            }
	    out.close();
        }catch(Exception e){
        	e.printStackTrace();
        }
	}
}
