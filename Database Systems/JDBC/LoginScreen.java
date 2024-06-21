package netapp;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.*;

public class LoginScreen extends JFrame implements ActionListener {
	private static final String DB_URL = "jdbc:postgresql://localhost:5432/Project1_db";
    private static final String DB_USER = "postgres";
    private static final String DB_PASSWORD = "admin";
    
    private JTextField emailField;
    private JTextField passField;
    private JButton loginButton;
    
    private Connection conn;
    
    public LoginScreen() {
        setTitle("Login");
        setSize(300, 150);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);

        emailField = new JTextField(20);
        
        passField = new JPasswordField();
        
        loginButton = new JButton("Login");

        JPanel panel = new JPanel(new GridLayout(5, 1));
        panel.add(new JLabel("Email:"));
        panel.add(emailField);
        panel.add(new JLabel("Password:"));
        panel.add(passField);
        panel.add(loginButton);

        add(panel, BorderLayout.CENTER);
        
        loginButton.addActionListener(this);
  
        checkJDBCdriver();
        dbConnect();
    }
    
    public void showMessage(String msg) {
    	JOptionPane.showMessageDialog(null, msg);
    }
    
    private void checkJDBCdriver() {
    	//Check if a valid driver is available
    	try {
        	Class.forName("org.postgresql.Driver");
        } catch(Exception e) {
           	 e.printStackTrace();
        }
    	
    }
    
    private void dbConnect() {
    	//Connect to professional network database
    	try {
			conn = DriverManager.getConnection(DB_URL,DB_USER,DB_PASSWORD);
			if (conn != null) {
	    		System.out.println("Connected to database succesfully!");
	    	} else {
	    		System.out.println("Connection failed!");
	    	}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    private boolean authenticateUser(String email, String password) throws SQLException {
    	//Check the user and password
    	String query = "SELECT email, the_password FROM member WHERE email = ?";
    	// Use of PreparedStatement to protect the system from injections
    	PreparedStatement statement = conn.prepareStatement(query);
    	statement.setString(1, email);
    	ResultSet resultSet = statement.executeQuery();
    	if (resultSet.next()) {
    		System.out.println(resultSet.getString("email"));
    		if ((email.equals(resultSet.getString("email"))) && (password.equals(resultSet.getString("the_password")))) {
    			return true;
    		}
    	}
    	return false;
    }

    @ Override
	public void actionPerformed(ActionEvent e){
		//Perform necessary actions when the login button is pressed
		Boolean authentication_result;
		try {
			authentication_result = authenticateUser(emailField.getText(), passField.getText());
			if (authentication_result == true) {
				System.out.println("Authentication completed succesfully");
				new MainScreen(conn, emailField.getText()).setVisible(true);
			} else {
				showMessage("User authentication failed. Try again!");
			}
		} catch (SQLException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
	}

    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            @Override
            public void run() {
                new LoginScreen().setVisible(true);
            }
        });
    }


}
