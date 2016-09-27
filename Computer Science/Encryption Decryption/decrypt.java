import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Scanner;


public class decrypt {
	public static void main (String [] args) throws IOException  {
		decrypt();
	}
	public static void decrypt () throws IOException {
		int key;		
		Scanner input = new Scanner(System.in);		
		
		System.out.println("enter the name of file to decrypt");
		String outputFilename = input.next();		
		PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(outputFilename+".decrypted", true)));
		
		System.out.println("Enter the key byte the range of -128 to 127"); 
		key = input.nextInt();		
		
    	FileInputStream fileInputStream=null;    	 
        File file = new File(outputFilename); 
        byte[] bFile = new byte[(int) file.length()];
        byte a;
        try {
            //convert file into array of bytes
	    fileInputStream = new FileInputStream(file);
	    fileInputStream.read(bFile);
	    fileInputStream.close();
 
	    for (int i = 0; i < bFile.length; i++) {
	    	a = (byte)(bFile[i] - key);
	    	out.print((char)a);
	    	System.out.println((char)a);
            }
	    out.close();
        }catch(Exception e){
        	e.printStackTrace();
        }
	}
}
