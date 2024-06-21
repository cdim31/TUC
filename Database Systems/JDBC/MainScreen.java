package netapp;

import javax.swing.*;
import javax.swing.border.Border;
import javax.swing.border.EmptyBorder;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Date;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;

public class MainScreen extends JFrame implements ActionListener, ListSelectionListener{
    private Connection conn;

    private String userEmail;
    
    private JPanel personalDetailsPanel;
    private JTextField firstNameField;
    private JTextField lastNameField;
    private JTextField dobField;
    private JTextField countryField;
    private JButton updateButton;
    
    private JList<Member> networkList;
    private DefaultListModel<Member> networkListModel;
    
    

    public MainScreen(Connection conn, String userEmail) {
        this.conn = conn;
        this.userEmail = userEmail;

        setTitle("Home");
        setSize(800, 500);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        this.getContentPane().setLayout(new BoxLayout(this.getContentPane(), BoxLayout.Y_AXIS));
        
        personalDetailsPanel = new JPanel(new GridLayout(5, 2,10,10));
        personalDetailsPanel.setMaximumSize(new Dimension(600,200));
        personalDetailsPanel.setBorder(new EmptyBorder(10,10,10,10));
        personalDetailsPanel.setAlignmentX(Component.LEFT_ALIGNMENT);
        
        personalDetailsPanel.add(new JPanel(new FlowLayout(FlowLayout.TRAILING)).add(new JLabel("First Name:")));
        firstNameField = new JTextField();
        personalDetailsPanel.add(firstNameField);

        personalDetailsPanel.add(new JLabel("Last Name:"));
        lastNameField = new JTextField();
        personalDetailsPanel.add(lastNameField);

        personalDetailsPanel.add(new JLabel("Date of Birth:"));
        dobField = new JTextField();
        personalDetailsPanel.add(dobField);
        
        personalDetailsPanel.add(new JLabel("Country:"));
        countryField = new JTextField();
        personalDetailsPanel.add(countryField);

        personalDetailsPanel.add(new JLabel());
        updateButton = new JButton("Update");
        updateButton.addActionListener(this);
        personalDetailsPanel.add(updateButton);

        networkListModel = new DefaultListModel<>();
        networkList = new JList<>(networkListModel);
        networkList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        networkList.addListSelectionListener(this);
        
        add(personalDetailsPanel);
        JLabel nusers = new JLabel("My Network");
        nusers.setAlignmentX(Component.LEFT_ALIGNMENT);
        add(nusers);
        JScrollPane jpane = new JScrollPane(networkList);
        jpane.setAlignmentX(Component.LEFT_ALIGNMENT);
        jpane.setBorder(new EmptyBorder(10,10,10,10));
        add(jpane);

        fetchPersonalDetails();
        fetchNetwork();
    }
    
    public void showMessage(String msg) {
    	JOptionPane.showMessageDialog(null, msg);
    }
    
    private void fetchPersonalDetails() {
    	// Write code to show the appropriate values in the JTextFields
    	String query = "SELECT email, first_name, second_name, date_of_birth, country"
    			+ " FROM member WHERE email = ?";
    	// Use of PreparedStatement to protect the system from injections
    	PreparedStatement statement;
		try {
			statement = conn.prepareStatement(query);
			statement.setString(1, userEmail);
	    	ResultSet resultSet = statement.executeQuery();
	    	if (resultSet.next()) {
	    		if (userEmail.equals(resultSet.getString("email"))) {
	    			firstNameField.setText(resultSet.getString("first_name"));
	    			lastNameField.setText(resultSet.getString("second_name"));
	    			dobField.setText(resultSet.getString("date_of_birth"));
	    			countryField.setText(resultSet.getString("country"));
	    		}
	    	}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }
    
    private void updatePersonalDetails() {
    	// Write code to update the database with new values in the JTextFields
    	DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    	Date dobDate;
    	try {
			dobDate = dateFormat.parse(dobField.getText());
			java.sql.Date sqlDate = new java.sql.Date(dobDate.getTime());
		 
			String command = "UPDATE member SET first_name = ?, second_name = ?,"
    			+ "date_of_birth = ?, country = ? WHERE email = ?";
			// Use of PreparedStatement to protect the system from injections
			PreparedStatement statement;
			try {
				statement = conn.prepareStatement(command);
				statement.setString(1, firstNameField.getText());
				statement.setString(2, lastNameField.getText());
				statement.setDate(3, sqlDate);
				statement.setString(4, countryField.getText());
				statement.setString(5, userEmail);
				statement.executeUpdate();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} }catch (ParseException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
		}   	
    }

    private void fetchNetwork() {
    	// Write code to fill the list with connected members
    	DefaultListModel<Member> listModel = new DefaultListModel<>();
    	String query = "SELECT email, connected_with_email FROM connects WHERE email = ?";
    	// Use of PreparedStatement to protect the system from injections
    	PreparedStatement statement;
		try {
			statement = conn.prepareStatement(query);
			statement.setString(1, userEmail);
	    	ResultSet resultSet = statement.executeQuery();
	    	while (resultSet.next()) {
	    		if (userEmail.equals(resultSet.getString("email"))) {
	    	    	String con_mem_email = resultSet.getString("connected_with_email");
	    	    	String final_query = "SELECT * FROM member WHERE email = ?";
	    	    	// Use of PreparedStatement to protect the system from injections
	    	    	PreparedStatement final_statement;
	    			final_statement = conn.prepareStatement(final_query);
	    			final_statement.setString(1, con_mem_email);
	    		    ResultSet rSet = final_statement.executeQuery();
	    		    while (rSet.next()) {
	    		    	if (con_mem_email.equals(rSet.getString("email"))){
	    		    		String fname = rSet.getString("first_name");
	    		    		String sname = rSet.getString("second_name");
	    		    		String email = rSet.getString("email");
	    		    		Member member = new Member(fname, sname, email);
	    		    		listModel.addElement(member);
	    		
	    		    	}
	    		    }
	    		}
	    	}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		networkList.setModel(listModel);
    }

	@Override
	public void actionPerformed(ActionEvent e) {
		//Perform necessary actions when the Update button is pressed
		updatePersonalDetails();
		fetchPersonalDetails();
	}
	
	@Override
	public void valueChanged(ListSelectionEvent e) {
        if (!e.getValueIsAdjusting()) {
            if (!networkList.isSelectionEmpty()) {
                Member selectedMember = networkList.getSelectedValue();
                new MemberDetailScreen(conn, selectedMember.getEmail()).setVisible(true);
            }
        }
    }
}
