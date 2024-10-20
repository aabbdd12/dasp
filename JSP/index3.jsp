<html>

<head>
<meta name="GENERATOR" content="Microsoft FrontPage 5.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<title>DAD-NEW</title>
</head>

<frameset rows="78,*" framespacing="0" border="0" frameborder="0" name="page">
  <frame name="banniere" scrolling="no" noresize target="sommaire" src="../entete.htm" marginwidth="0" marginheight="0">
  <frameset cols="130,*">
    <frame name="sommaire" target="principal" scrolling="no" marginwidth="0" marginheight="0" noresize src="ECNMenu.jsp">
<%
String message = (String)request.getParameter("message");  
 if (message!=null)
   {
   %> 
    <frame name="main" scrolling="auto" src="ECNLogin.jsp?message=error" target="_top">

<%} else {%>
	   
    <frame name="principal" src="ECNLogin.jsp" target="_top">
<%}%>


  </frameset>
  <noframes>
  <body>

  <p>Cette page utilise des cadres, mais votre navigateur ne les prend pas en 
  charge.</p>

  </body>
  </noframes>
</frameset>

</html>