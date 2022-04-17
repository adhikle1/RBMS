package edu.binghamton;

import edu.binghamton.worker.MainWorker;
import oracle.jdbc.pool.OracleDataSource;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void main( String[] args )
    {
        OracleDataSource ds;
        try {
            System.out.println("Welcome to Retail Business Management System");
            BufferedReader sysIn = new BufferedReader(new InputStreamReader(System.in));
            String userName = "trasal1";
            String password = "TsincosR34";
            ds = new oracle.jdbc.pool.OracleDataSource();

            ds.setURL("jdbc:oracle:thin:@castor.cc.binghamton.edu:1521:acad111");

            MainWorker worker = new MainWorker(sysIn, ds, userName, password);
            worker.process();
        } catch (SQLException e) {
            System.out.println("Unable to establish connection with DB server...!!");
        }
    }


}
