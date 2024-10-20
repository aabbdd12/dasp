<%@ page import="java.sql.* , java.io.* ,java.util.* " %> 
<jsp:useBean id="servlet"  class="Mimap.DADUser" />

<%@page contentType="text/html"%>
<html>
<head><title>DAD</title></head>
<body>

 <%servlet.DeleteUser((String) request.getParameter("userid"));%>

  <jsp:forward page="ECNDownload.jsp"/>

<%-- <jsp:useBean id="beanInstanceName" scope="session" class="package.class" /> --%>
<%-- <jsp:getProperty name="beanInstanceName"  property="propertyName" /> --%>

</body>
</html>
