
<%@ page import="java.sql.* ,java.util.*, Mimap.DADUser " %> 
<jsp:useBean id="query2"  class="Mimap.DADUser" />

<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<meta name="GENERATOR" content="Microsoft FrontPage 5.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<title>PEP-NET.org</title>
</head>

<body>

<table border="1" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#E4E9FF" width="600" id="AutoNumber1" bgcolor="#E4E9FF">
  <tr>
    <td width="100%"><b>MEMBER INFORMATION</b></td>
  </tr>
</table>
<div align="left">
  <table cellspacing="1" width="547" bordercolorlight="#0000FF" border="0" height="428">
    <tbody>
    <% 
                    ResultSet rs5;
                    
                    rs5 = query2.queryUser2("USERID",request.getParameter("userid")); 
                    while (rs5.next())
                    {
            
                    String userid= rs5.getString("USERID");
                    

String lastmodif="";
String lastmod = rs5.getString("CREATIONDATE");     
        if (lastmod==null)
        	lastmod=" ";
        else
        lastmodif = lastmod.substring(6,8)+"-"+lastmod.substring(4,6)+"-"+lastmod.substring(0,4);
        %>

      <tr>
        <td align="right" width="184" height="21">
        &nbsp;</td>
        <td align="left" width="11" height="21">&nbsp;</td>
        <th width="342" height="21" align="left">&nbsp;</th>
      </tr>

      <tr>
        <td align="right" width="184" height="21">
        </td>
        <td align="left" width="11" height="21">&nbsp;</td>
        <th width="342" height="21" align="center" bgcolor="#EEEEEE"><font size="1" face="Times New Roman">&nbsp;</font>Last Update: <%=lastmodif%></th>
       
        </tr>
                    

      <tr>
        <td align="right" width="184" height="21">
        &nbsp;</td>
        <td align="left" width="11" height="21">&nbsp;</td>
        <th width="342" height="21" align="left">&nbsp;</th>
      </tr>
                    

      <tr>
        <td align="right" width="184" height="21">
        <font size="2" color="#0000FF"><b>Title:</b></font></td>
        <td align="left" width="11" height="21">&nbsp;</td>
        <% String salutation = rs5.getString("SALUTATION");
        if (salutation==null)
        	salutation=" ";
        %>
        <th width="342" height="21" align="left"><%= salutation%></th>
      </tr>
      <tr>
        <td align="right" width="184" height="21">
        <font size="2" color="#0000FF"><b>First Name:</b></font></td>
        <td align="left" width="11" height="21">&nbsp;</td>
        <th width="342" height="21" align="left"><%= rs5.getString("FIRSTNAME")%></th>
      </tr>
      <tr>
        <td align="right" width="184" height="21">
        <font size="2" color="#0000FF"><b>Last Name:</b></font></td>
        <td align="left" width="11" height="21">&nbsp;</td>
        <th width="342" height="21" align="left"><%= rs5.getString("LASTNAME")%></th>
      </tr>
      <%String mail = rs5.getString("EMAIL");
       
        
        if (mail==null)
        	mail=" ";
		
        %>
      <tr>
        <td align="right" width="184" height="21">
        <font size="2" color="#0000FF"><b>E-Mail: </b></font></td>
        <td align="left" width="11" height="21">&nbsp;</td>
        
        <th width="342" height="21" align="left"><a href="mailto:<%=mail%>"><%= mail%></a></th>
      </tr>
      
      <tr>
        <td align="right" width="184" height="21">
        <font size="2" color="#0000FF"><b>Phone:</b></font></td>
        <td align="left" width="11" height="21">&nbsp;</td>
         <% String phone = rs5.getString("PHONE");
        if (phone==null)
        	phone=" ";
        %>

        <th width="342" height="21" align="left"><%= phone%></th>
      </tr>
     
      <tr>
        <td width="184" align="right" height="21">
        <font size="2" color="#0000FF"><b>Address:</b></font></td>
        <td width="11" align="left" height="21">&nbsp;</td>
        <% String address = rs5.getString("ADDRESS");
        if (address==null)
        	address=" ";
        %>

        <th width="342" height="21" align="left"><%= address%></th>
      </tr>
      <tr>
        <td width="184" align="right" height="21">
        <font size="2" color="#0000FF"><b>City:</b></font></td>
        <td width="11" align="left" height="21">&nbsp;</td>
        <% String city = rs5.getString("CITY");
        if (city==null)
        	city=" ";
        %>

        <th width="342" height="21" align="left"><%= city%></th>
      </tr>
      <tr>
        <td width="184" align="right" height="21">
        <font size="2" color="#0000FF"><b>State/Province:</b></font></td>
        <td width="11" align="left" height="21">&nbsp;</td>
        <% String state = rs5.getString("STATE");
        if (state==null)
        	state=" ";
        %>

        <th width="342" height="21" align="left"><%= state%></th>
      </tr>
      <tr>
        <td width="184" align="right" height="21">
        <font size="2" color="#0000FF"><b>Country:</b></font></td>
        <td width="11" align="left" height="21">&nbsp;</td>
        <% String country = rs5.getString("COUNTRY");
        if (country==null)
        	country=" ";
        %>

        <th width="342" height="21" align="left"><%= country%></th>
      </tr>
      <tr>
        <td width="184" align="right" height="21">
        <font size="2" color="#0000FF"><b>Postal Code:</b></font></td>
        <td width="11" align="left" height="21">&nbsp;</td>
        <% String postalcode = rs5.getString("POSTALCODE");
        if (postalcode==null)
        	postalcode=" ";
        %>

        <th width="342" height="21" align="left"><%= postalcode%></th>
      </tr>
     
     
      <tr>
        <td width="184" align="right" height="21">
        <font size="2" color="#0000FF"><b>Institution:</b></font></td>
        <td width="11" align="left" height="21">&nbsp;</td>
        <% String institution = rs5.getString("INSTITUTION");
        if (institution==null)
        	institution=" ";
        %>

        <th width="342" height="21" align="left"><%= institution%></th>
      </tr>
     
    
      <%}%>
    </tbody>
    
  </table>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>

</body>

</html>