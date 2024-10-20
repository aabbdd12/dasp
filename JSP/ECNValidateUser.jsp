<%@page contentType="text/html"%>
<html>
<head><title>JSP Page</title></head>
<body>

<%@ page import="java.sql.* , java.io.* ,java.util.* , Mimap.DADDBConnection" %> 
<jsp:useBean id="servlet"  class="Mimap.DADDBConnection" />

<% 

    String [][] valeur = new String [2][2];
    valeur[0][0] = "USERNAME";
    valeur[0][1] = (String) request.getParameter("USERID");
    valeur[1][0] = "PASSWORD";
    valeur[1][1] = (String) request.getParameter("PASSWORD");

%>

<%!          ResultSet rs;  
             String userid;
             String username;
		 String lastname;
		 String email;
%>
<%
             servlet.ConnectDB();
             rs = servlet.checkLogin(valeur);
            
              if (rs.next()){
                userid = rs.getString("USERID");
                username = rs.getString("FIRSTNAME");
		lastname = rs.getString("LASTNAME");
		application.setAttribute("nom",username);
                application.setAttribute("id",userid);
                session.setAttribute("userid",userid);
                session.setAttribute("username",username);
                session.setAttribute("lastname",lastname);
		
                %>
                <!--% response.sendRedirect("ECNServices.jsp"); %-->
                <jsp:forward page="ECNServices.jsp" />
                <%    
             
                }
                else
                {
            
                response.sendRedirect("ECNLogin.jsp?message=error"); 
                }
                %>
              
</body>
</html>