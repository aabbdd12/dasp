<%@ page import="java.sql.* , java.io.* ,java.util.*, Mimap.DADUser " %> 
<jsp:useBean id="query"  class="Mimap.DADUser"  />
<jsp:useBean id="connection"  class="Mimap.DADDBConnection" />

    


<%  
    connection.ConnectDB();
    String stringToQuery =  request.getParameter("STRINGTOSEARCH");
    String objectType = request.getParameter("ATTRIBUTE");
    application.setAttribute("attributetype",objectType);
    application.setAttribute("stringToQuery",stringToQuery);

    if(objectType.compareTo("MAILLIST")==0)
    {

    if(stringToQuery.compareTo("ALL")==0)
        {
        query.queryAllUser2();
        //query.queryUser3(objectType,stringToQuery);
        }
   
    else
        {
        query.queryUser3(objectType,stringToQuery);
        }
    }
        %>
<jsp:forward page="ECNUserCreateMail.jsp"/>