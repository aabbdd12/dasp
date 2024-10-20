<%@page contentType="text/html"%>
<html>
<head><title>DASP</title></head>
<body>

<%@ page import="java.sql.* , java.io.* ,java.util.* " %> 
<jsp:useBean id="servlet"  class="Mimap.DASPUser" />

<% 


    String date = (String) request.getParameter("year")+"-"+(String) request.getParameter("month")+"-"+(String) request.getParameter("day");
    String confnum = (String) request.getParameter("confnumber");
    String useridtmp = (String) request.getParameter("userid2");
    servlet.confirmSendCD(date,confnum,useridtmp);

                %>
                <!--% response.sendRedirect("ECNServices.jsp"); %-->
                <jsp:forward page="DASPUpdateCD.jsp" />
                
              
</body>
</html>