<%@ page import="java.sql.* , java.io.* ,java.util.*, Mimap.DADUser " %> 
<jsp:useBean id="query"  class="Mimap.DADUser"  />
<jsp:useBean id="connection"  class="Mimap.DADDBConnection" />

    


<%  
    connection.ConnectDB();
    String objectType = request.getParameter("ATTRIBUTE");
     ResultSet rs;

   // if(objectType.compareTo("ALL")==0 ){
        rs = query.queryAllUser();
     //   }
   
  //  else
    //    {
     //   rs = query.queryUser("WORKINGGROUP",objectType);
     //   }

    String mailto="";

    while (rs.next())
    {
	
    String test = request.getParameter(rs.getString("USERID"));

    if (test !=null)
        {
	mailto=mailto+test+";";
        
        }
	
    }

	out.println("<a href=MAILTO:"+mailto+">Launch Mail Application \n");

        %>


