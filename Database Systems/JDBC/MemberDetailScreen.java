package netapp;

import javax.swing.*;
import javax.swing.border.EmptyBorder;

import java.awt.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MemberDetailScreen extends JFrame {
    private Connection conn;
    private String memberEmail;
    private JTextArea detailsArea;
    private JTextArea messagesArea;
    private JTextArea educationArea;
    private JTextArea experienceArea;

    public MemberDetailScreen(Connection conn, String memberEmail) {
        this.conn = conn;
        this.memberEmail = memberEmail;

        setTitle("Details for :"+memberEmail);
        setSize(600, 700);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);

        detailsArea = new JTextArea(5, 40);
        detailsArea.setEditable(false);
        messagesArea = new JTextArea(10, 40);
        messagesArea.setEditable(false);
        educationArea = new JTextArea(10, 40);
        educationArea.setEditable(false);
        experienceArea = new JTextArea(10, 40);
        experienceArea.setEditable(false);

        JPanel panel = new JPanel(new GridLayout(4, 1));
        panel.setBorder(new EmptyBorder(20,20,20,20));
        
        panel.add(new JLabel("Personal Details"));
        panel.add(new JScrollPane(detailsArea));
        panel.add(new JLabel("Messages"));
        panel.add(new JScrollPane(messagesArea));
        panel.add(new JLabel("Education"));
        panel.add(new JScrollPane(educationArea));
        panel.add(new JLabel("Experience"));
        panel.add(new JScrollPane(experienceArea));

        add(panel);

        fetchMemberDetails();
        fetchMessages();
        fetchEducation();
        fetchExperience();
    }

    private void fetchMemberDetails() {
    	// Write code to show member's details to the appropriate JTextArea
    	String query = "SELECT email, first_name, second_name, date_of_birth, country, gender"
    			+ " FROM member WHERE email = ?";
    	// Use of PreparedStatement to protect the system from injections
    	PreparedStatement statement;
		try {
			statement = conn.prepareStatement(query);
			statement.setString(1, memberEmail);
	    	ResultSet resultSet = statement.executeQuery();
	    	if (resultSet.next()) {
	    		if (memberEmail.equals(resultSet.getString("email"))) {
	    			detailsArea.setText("Fullname: " + resultSet.getString("first_name")+" "+ 
	    								resultSet.getString("second_name")+"\n");
	    			detailsArea.append("Email: " + resultSet.getString("email")+"\n");
	    			detailsArea.append("Date of Birth:" +resultSet.getString("date_of_birth")+"\n");
	    			detailsArea.append("Gender: " + resultSet.getString("gender")+"\n");	    			
	    			detailsArea.append("Country: " + resultSet.getString("country")+"\n");
	    		}
	    	}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    private void fetchMessages() {
    	// Write code to show messages from member to the appropriate JTextArea
    	String query = "SELECT the_text, receiver_email"
    			+ " FROM msg WHERE receiver_email = ?";
    	// Use of PreparedStatement to protect the system from injections
    	PreparedStatement statement;
		try {
			statement = conn.prepareStatement(query);
			statement.setString(1, memberEmail);
	    	ResultSet resultSet = statement.executeQuery();
	    	while (resultSet.next()) {
	    		if (memberEmail.equals(resultSet.getString("receiver_email"))) {
	    			messagesArea.append(resultSet.getString("the_text")+"\n");
	    		}
	    	}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    private void fetchEducation() {
    	// Write code to show member's details about education the appropriate JTextArea
    	String query = "SELECT email, from_year, to_year, country,"
    			+ "	school, edu_level, category_id"
    			+ "	FROM education WHERE email = ?";
    	// Use of PreparedStatement to protect the system from injections
    	PreparedStatement statement;
		try {
			statement = conn.prepareStatement(query);
			statement.setString(1, memberEmail);
	    	ResultSet resultSet = statement.executeQuery();
	    	while (resultSet.next()) {
	    		if (memberEmail.equals(resultSet.getString("email"))) {
	    			educationArea.append("Country: "+ resultSet.getString("country")+"\n");
	    			educationArea.append("School: "+ resultSet.getString("school")+"\n");
	    			educationArea.append("Level: "+ resultSet.getString("edu_level")+"\n");
	    			educationArea.append("Category: "+ resultSet.getString("category_id")+"\n");
	    			educationArea.append("From: "+ resultSet.getString("from_year")+"\n");
	    			educationArea.append("To: "+ resultSet.getString("to_year")+"\n");
	    			educationArea.append("\n");
	    		}
	    	}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    private void fetchExperience() {
    	// Write code to show member's professional experience to the appropriate JTextArea
    	String query = "SELECT email, company, workstatus, title,"
    			+ "	description, from_year, to_year"
    			+ "	FROM experience WHERE email = ?";
    	// Use of PreparedStatement to protect the system from injections
    	PreparedStatement statement;
		try {
			statement = conn.prepareStatement(query);
			statement.setString(1, memberEmail);
	    	ResultSet resultSet = statement.executeQuery();
	    	while (resultSet.next()) {
	    		if (memberEmail.equals(resultSet.getString("email"))) {
	    			experienceArea.append("Company: "+ resultSet.getString("company")+"\n");
	    			experienceArea.append("Status: "+ resultSet.getString("workstatus")+"\n");
	    			experienceArea.append("Title: "+ resultSet.getString("title")+"\n");
	    			experienceArea.append("Description: "+ resultSet.getString("description")+"\n");
	    			experienceArea.append("From: "+ resultSet.getString("from_year")+"\n");
	    			experienceArea.append("To: "+ resultSet.getString("to_year")+"\n");
	    			experienceArea.append("\n");
	    		}
	    	}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }
}

