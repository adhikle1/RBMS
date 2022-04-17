package edu.binghamton.worker;

import oracle.jdbc.OracleTypes;
import oracle.jdbc.pool.OracleDataSource;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.*;

public class MainWorker {

    private OracleDataSource ds;
    private BufferedReader inputReader;
    private String userName;
    private String password;

    public MainWorker(BufferedReader sysIn, OracleDataSource ds, String userName, String password) {
        this.inputReader = sysIn;
        this.ds = ds;
        this.userName = userName;
        this.password = password;
    }

    public void process() {
        int choice = 0;

        while (choice != 6) {
            printMainMenu();
            choice = readIntegerFromUser();
            switch (choice) {
                case 1:
                    handleDisplayTable();
                    break;
                case 2:
                    handlePurchasesMade();
                    break;
                case 3:
                    handleNumberOfCustomers();
                    break;
                case 4:
                    handleAddCustomer();
                    break;
                case 5:
                    handleAddPurchase();
                    break;
                case 6:
                    break;
                default:
                    System.out.println("Invalid Choice!! Please enter a valid Choice!");
                    break;
            }
        }
    }

    private void handlePurchasesMade() {
        System.out.println("Enter Customer Id: ");
        String cid = readStringFromUser();
        try(Connection conn = ds.getConnection(userName, password)) {
            CallableStatement cs = conn.prepareCall("begin RBMS.purchases_made(?,?); end;");
            cs.setString(1, cid);
            cs.registerOutParameter(2, OracleTypes.CURSOR);
            cs.execute();

            ResultSet rs = (ResultSet)cs.getObject(2);
            ResultSetMetaData rsmd = rs.getMetaData();
            printColumnTitles(rsmd);
            int num_col = rsmd.getColumnCount();

            while(rs.next()){
                for(int i = 1;i<=num_col;i++){
                    System.out.format("%-20s", rs.getString(i));
                }
                System.out.print("\n");
            }
            cs.close();

        } catch (SQLException e) {
            String ex = e.getMessage().split("\n")[0].split(": ")[1];
            System.out.println(ex + "\n");
        }
    }

    private void handleNumberOfCustomers() {
        System.out.println("Enter Product Id: ");
        String pid = readStringFromUser();
        try(Connection conn = ds.getConnection(userName, password)) {
            CallableStatement cs = conn.prepareCall("{? = call RBMS.number_customers(?)}");
            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, pid);
            cs.executeUpdate();

            int purchasesCount = cs.getInt(1);
            System.out.print("Number of customers purchased product (" + pid + ") is: "+ purchasesCount+"\n");

        } catch (SQLException e) {
            String ex = e.getMessage().split("\n")[0].split(": ")[1];
            System.out.println(ex + "\n");
        }
    }

    private void handleAddCustomer() {
        System.out.println("Enter Customer Id: ");
        String cid = readStringFromUser();
        System.out.println("Enter Customer Name: ");
        String name = readStringFromUser();
        System.out.println("Enter Customer Telephone number in format XXX-XXX-XXXX: ");
        String telephone = readStringFromUser();
        String validPhoneRegEx = "\\d{3}[-.]\\d{3}[-.]\\d{4}$";
        if(!telephone.matches(validPhoneRegEx)) {
            System.out.println("Phone number is not valid format. Please use format XXX-XXX-XXXX");
            return;
        }
        try(Connection conn = ds.getConnection(userName, password)) {
            CallableStatement cs = conn.prepareCall("begin RBMS.add_customer(?,?,?); end;");
            cs.setString(1, cid);
            cs.setString(2, name);
            cs.setString(3, telephone);

            cs.executeUpdate();
            System.out.println("Customer added successfully.\n");
        } catch (SQLException e) {
            String ex = e.getMessage().split("\n")[0].split(": ")[1];
            System.out.println(ex + "\n");
        }
    }

    private void handleAddPurchase() {
        System.out.println("Enter Employee Id: ");
        String eid = readStringFromUser();
        System.out.println("Enter Product Id: ");
        String pid = readStringFromUser();
        System.out.println("Enter Customer Id: ");
        String cid = readStringFromUser();
        System.out.println("Enter Quantity: ");
        int quantity = readIntegerFromUser();
        System.out.println("Enter Unit Price of Purchase: ");
        int unitPrice = readIntegerFromUser();
        try(Connection conn = ds.getConnection(userName, password)) {
            CallableStatement cs = conn.prepareCall("begin RBMS.add_purchase(?,?,?,?,?,?,?); end;");
            cs.setString(1, eid);
            cs.setString(2, pid);
            cs.setString(3, cid);
            cs.setString(4, Integer.toString(quantity));
            cs.setString(5, Integer.toString(unitPrice));
            cs.registerOutParameter(6,OracleTypes.NUMBER);
            cs.registerOutParameter(7,OracleTypes.NUMBER);

            cs.executeUpdate();
            System.out.println("Purchase added successfully.\n");

            int isQohReset = cs.getInt(6);
            int newQoh = cs.getInt(7);
            if(isQohReset == 1) {
                System.out.println("The current qoh of the product is below the required threshold and new supply is required.");
                System.out.println("New quantity updated to "+newQoh +"\n");
            }
        } catch (SQLException e) {
            String ex = e.getMessage().split("\n")[0].split(": ")[1];
            System.out.println(ex + "\n");
        }
    }

    private void handleDisplayTable() {
        int subChoice = 0;
        while(subChoice != 6) {
            printSubMenu();
            subChoice = readIntegerFromUser();
            switch (subChoice) {
                case 1:
                    printTuples("employees");
                    break;
                case 2:
                    printTuples("customers");
                    break;
                case 3:
                    printTuples("products");
                    break;
                case 4:
                    printTuples("purchases");
                    break;
                case 5:
                    printTuples("logs");
                    break;
                case 6:
                    break;
                default:
                    System.out.println("Invalid Choice!! Please enter a valid Choice!");
                    break;
            }
        }
    }

    public void printTuples(String tableName) {
        try(Connection conn = ds.getConnection(userName, password)) {

            CallableStatement cs = conn.prepareCall("begin RBMS.show_" + tableName + "(?); end;");
            cs.registerOutParameter(1, OracleTypes.CURSOR);
            // execute and retrieve the result set
            cs.execute();
            ResultSet rs = (ResultSet)cs.getObject(1);
            ResultSetMetaData rsmd = rs.getMetaData();
            printColumnTitles(rsmd);
            int num_col = rsmd.getColumnCount();

            while(rs.next()){
                for(int i = 1;i<=num_col;i++){
                    System.out.format("%-20s", rs.getString(i));
                }
                System.out.print("\n");
            }
            cs.close();
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("SQL exception caught during printTuples()!");
        }
    }

    public void printColumnTitles(ResultSetMetaData rsmdIn) throws SQLException {
        int num_col = rsmdIn.getColumnCount();
        for(int i = 1; i<=num_col; i++){
            System.out.format("%-20s", rsmdIn.getColumnLabel(i));
        }
        System.out.println("\n");
    }

    private int readIntegerFromUser() {
        String input;
        int value = 0;
        try {
            input = inputReader.readLine();
            if (!input.isEmpty()) {
                value = Integer.parseInt(input);
            }
        } catch (IOException e) {
            System.out.println("Unable to read the input! Input may not be in correct format!");
            System.exit(0);
        }
        return value;
    }

    private String readStringFromUser() {
        String input = "";
        try {
            input = inputReader.readLine();
        } catch (IOException e) {
            System.out.println("Unable to read the input!");
            System.exit(0);
        }
        return input;
    }

    private void printMainMenu(){
        System.out.println("--------------User Menu------------------\n1.Display a Table.\n2.Purchases made by customer.\n3.Number of customers purchased the product."
                + "\n4.Add customer.\n5.Add Purchase.\n6.Exit.\nEnter a Choice:");
    }

    public void printSubMenu(){
        System.out.println("1.Show Employees\n2.Show Customers\n3.Show Products\n4.Show Purchases\n5.Show Logs\n6.Go back to previous menu\nEnter a Choice:");
    }
}
