<%@page contentType="text/html"%>
<html>

<head>
<title>DAD</title>
</head>
<body>

<%@ page import="java.sql.* , java.io.* ,java.util.*, Mimap.DADUserForm " %>
<jsp:useBean id="servlet" class="Mimap.DADUserForm" />
<jsp:useBean id="userservlet" class="Mimap.DADUser" />
<%!String  user= "" ;
   String updatepassword="";
   int useridnewuser =0;
   String prenom = "";
   String nom = "";
%> <% 
        

	//updatepassword = (String) request.getParameter("updatepassword");

	
        try{
        prenom = (String) request.getParameter("firstname");
        nom = (String) request.getParameter("lastname");
        servlet.setSalutation((String) request.getParameter("salutation"));
        servlet.setFirstName(prenom);
        servlet.setLastName(nom);
        servlet.setEmail((String) request.getParameter("email"));
        servlet.setInstitution((String) request.getParameter("institution"));
        servlet.setAddress((String) request.getParameter("address"));
        servlet.setCity((String) request.getParameter("city"));
        servlet.setState((String) request.getParameter("state"));
        servlet.setZip((String) request.getParameter("zip"));
        servlet.setCountry((String) request.getParameter("country"));
        servlet.setPhone((String) request.getParameter("phone"));
        servlet.setComment((String) request.getParameter("comment"));
        servlet.setMailingList((String) request.getParameter("maillist"));
        servlet.setSex((String) request.getParameter("sex"));
        }
catch (Exception e)
        {
        prenom = (String) request.getParameter("firstname");
        nom = (String) request.getParameter("lastname");
        servlet.setFirstName(prenom);
        servlet.setLastName(nom);
        servlet.setEmail((String) request.getParameter("email"));
       
        }
    
 


 if(servlet.validate())
            {
              
                
                user = (String)request.getParameter("user");
                try
                {
                
                // ON UPDATE L'USAGER

                if (user != null)
                    {
                    
                    
                    servlet.updateIntoDB(user);
                    %>
		<jsp:forward page="ECNDownload.jsp" /><%

                    }

                // ON CREER L'USAGER

                else
                    {
                        // ON VALIDE QUE L'USAGER N'EXISTE PAS
                        if(servlet.validateUsername())
                            {
                            ResultSet result = userservlet.queryNom(prenom,nom);
                            if (result.next()) {
                            session.setAttribute("email",result.getString("email"));
                            session.setAttribute("prenom",prenom);
                            session.setAttribute("nom",nom);%>
                            <jsp:forward page="ECNUserExistMessage.jsp?prenom1=<%=prenom%>&nom1=<%=nom%>" />
				
                            <%
                            }
                            result = userservlet.queryNom(nom,prenom);
                            if (result.next()) {
			    session.setAttribute("email",result.getString("email"));
                            
                            session.setAttribute("nom",prenom);
                            session.setAttribute("prenom",nom);%>
                            <jsp:forward page="ECNUserExistMessage.jsp?prenom1=<%=nom%>&nom1=<%=prenom%>" />
			
                            <%
                            }
                            // ON CREER L'USAGER DANS LA BASE

                            String subscription = (String) request.getParameter("subscription");
                            
                            if (subscription!=null)
			    {
                            if (subscription.compareTo("1")==0)
                                {
                                useridnewuser = servlet.writeIntoDB2();  // Non Officiel comme usager
				session.setAttribute("useridnewuser",String.valueOf(useridnewuser));

				%>
				<jsp:forward page="/servlet/DADSendMail?action=NEWUSER&userid=<%=useridnewuser%>" />
							<!--jsp:forward page="ECNLogin.jsp?message=OK"/--><%
                                }
                            else
                                {
                                useridnewuser = servlet.writeIntoDB();
                                session.setAttribute("useridnewuser",String.valueOf(useridnewuser));				

                                %>
                                <jsp:forward page="/servlet/DADSendMail1?action=NEWUSER&userid=<%=useridnewuser%>" />
								<%
                                }
				}
                            }
                       else
                            {
                            %>
                    <jsp:forward page="ECNSubscription.jsp?message=error" /><%}%> <%
                    }
                }
                catch (Exception e)
                {}

             %> <%
            }
 else
        {
        String error = servlet.getErrorMessage();
        %>
        <script>
            alert('<%=error%>','PEP Info')  
            history.back(2);
        </script> <% }

%>

</body>

</html>