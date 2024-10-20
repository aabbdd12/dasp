
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

<p>&nbsp;</p>

<table border="1" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#E4E9FF" width="600" id="AutoNumber1" bgcolor="#E4E9FF">
  <tr>
    <td width="100%"><b>MEMBER INFORMATION</b></td>
  </tr>
</table>
<div align="left">
  <table cellspacing="1" width="430" bordercolorlight="#0000FF" border="0" height="108">
    <tbody>
    <% 
                    ResultSet rs5;
                    
                    rs5 = query2.queryUser2("USERID",request.getParameter("userid")); 
                    while (rs5.next())
                    {
            
                    String userid= rs5.getString("USERID");%>
                    

      <tr>
        <td align="right" width="120" height="21">
        &nbsp;</td>
        <td align="left" width="20" height="21">&nbsp;</td>
        <th width="487" height="21" align="left">&nbsp;</th>
      </tr>
                    

      <tr>
<form method="POST" action="ECNAdminAcceptUser.jsp?userid=<%=userid%>">
<span style="font-size: 12.0pt; font-family: Times New Roman">
                  <td style="padding: 3pt" align="right" width="114" height="1">
                    <p class="MsoNormal" align="right"><font size="2"><span class="rednote">
                    <font color="#FF0000">
                    *<b>User Group:</b></font></span></font><b><font size="2"> </font></b><font size="2"><span style="FONT-FAMILY: 'Arial Unicode MS'">
                    <O:P>
                    </O:P>
                    </span></font></p>
                  </td>
                  <td style="padding: 3pt" width="20" height="1" align="left">
                    <p align="left">

<span style="font-size: 12.0pt; font-family: Times New Roman">
                    <select size="1" name="workinggroup">
                      <font size="2"><span style="FONT-FAMILY: 'Arial Unicode MS'">
                      <O:P>
                      </O:P>
                     
                          <option value="PMMA">PMMA
                          <option value="MPIA">MPIA
                          <option value="CBMS">CBMS</span></font>
                          <option value="OTHER">OTHER</span></font>
                           
 
                    </select></span></p>
                  </td>
                  </span>
                </tr>
                
                
                
     </table>
     <table>           
    <tr>
                  <td style="padding: 3pt" align="right" width="114" height="21">
                    &nbsp;</td>
                  <td style="padding: 3pt" width="20" height="1" align="left">
                  </td>
                  </tr>
                    

      <tr>
        <td align="right" width="120" height="1">
        
         <p><input type="submit" value="Accept This User" name="B1"></p>
        </form>
        </td>
        <td align="left" width="20" height="1"></td>
        <th width="487" height="1" align="left">
        <form method="POST" action="ECNAdminRejectUser.jsp?userid=<%=userid%>">
          <input type="submit" value="Reject User" name="reject"></p>
        </form>
        </th>
      </tr>
                    

      <tr>
        <td align="right" width="120" height="21">
        &nbsp;</td>
        <td align="left" width="20" height="21">&nbsp;</td>
        <th width="487" height="21" align="left">&nbsp;</th>
      </tr>
                    

      <tr>
        <td align="right" width="120" height="21">
        <font size="2" color="#0000FF"><b>Title:</b></font></td>
        <td align="left" width="20" height="21">&nbsp;</td>
        <th width="487" height="21" align="left"><%= rs5.getString("SALUTATION")%></th>
      </tr>
      <tr>
        <td align="right" width="120" height="21">
        <font size="2" color="#0000FF"><b>First Name:</b></font></td>
        <td align="left" width="20" height="21">&nbsp;</td>
        <th width="487" height="21" align="left"><%= rs5.getString("FIRSTNAME")%></th>
      </tr>
      <tr>
        <td align="right" width="120" height="21">
        <font size="2" color="#0000FF"><b>Last Name:</b></font></td>
        <td align="left" width="20" height="21">&nbsp;</td>
        <th width="487" height="21" align="left"><%= rs5.getString("LASTNAME")%></th>
      </tr>
      <%String mail = rs5.getString("EMAIL");
        String mail2 = rs5.getString("EMAIL2");
        String website = rs5.getString("WEBSITE");
        %>
      <tr>
        <td align="right" width="120" height="21">
        <font size="2" color="#0000FF"><b>E-Mail: </b></font></td>
        <td align="left" width="20" height="21">&nbsp;</td>
        
        <th width="487" height="21" align="left"><a href="mailto:<%=mail%>"><%= mail%></a></th>
      </tr>
      <tr>
        <td align="right" width="120" height="21">
        <font size="2" color="#0000FF"><b>E-Mail 2:</b></font></td>
        <td align="left" width="20" height="21">&nbsp;</td>
        <th width="487" height="21" align="left"><a href="mailto:<%=mail2%>"><%= mail2%></a></th>
      </tr>
      <tr>
        <td width="120" align="right" height="21">
        <font color="#0000FF" size="2"><b>Web site:</b></font>:</td>
        <td width="20" align="left" height="21">&nbsp;</td>
        <th width="487" height="21" align="left"><a href="<%=website%>"><%= website%></a></th>
      </tr>
      <tr>
        <td align="right" width="120" height="21">
        <font size="2" color="#0000FF"><b>Phone:</b></font></td>
        <td align="left" width="20" height="21">&nbsp;</td>
        <th width="487" height="21" align="left"><%= rs5.getString("PHONE")%></th>
      </tr>
      <tr>
        <td width="120" align="right" height="21">
        <font size="2" color="#0000FF"><b>Phone 2:</b></font></td>
        <td width="20" align="left" height="21">&nbsp;</td>
        <th width="487" height="21" align="left"><%= rs5.getString("PHONE2")%></th>
      </tr>
      <tr>
        <td width="120" align="right" height="21">
        <font size="2" color="#0000FF"><b>Address:</b></font></td>
        <td width="20" align="left" height="21">&nbsp;</td>
        <th width="487" height="21" align="left"><%= rs5.getString("ADDRESS")%></th>
      </tr>
      <tr>
        <td width="120" align="right" height="21">
        <font size="2" color="#0000FF"><b>City:</b></font></td>
        <td width="20" align="left" height="21">&nbsp;</td>
        <th width="487" height="21" align="left"><%= rs5.getString("CITY")%></th>
      </tr>
      <tr>
        <td width="120" align="right" height="21">
        <font size="2" color="#0000FF"><b>State/Province:</b></font></td>
        <td width="20" align="left" height="21">&nbsp;</td>
        <th width="487" height="21" align="left"><%= rs5.getString("STATE")%></th>
      </tr>
      <tr>
        <td width="120" align="right" height="21">
        <font size="2" color="#0000FF"><b>Country:</b></font></td>
        <td width="20" align="left" height="21">&nbsp;</td>
        <th width="487" height="21" align="left"><%= rs5.getString("COUNTRY")%></th>
      </tr>
      <tr>
        <td width="120" align="right" height="21">
        <font size="2" color="#0000FF"><b>Postal Code:</b></font></td>
        <td width="20" align="left" height="21">&nbsp;</td>
        <th width="487" height="21" align="left"><%= rs5.getString("POSTALCODE")%></th>
      </tr>
      <tr>
        <td width="120" align="right" height="21">
        <font size="2" color="#0000FF"><b>Fax Number:</b></font></td>
        <td width="20" align="left" height="21">&nbsp;</td>
        <th width="487" height="21" align="left"><%= rs5.getString("FAX")%></th>
      </tr>
      <tr>
        <td width="120" align="right" height="22">
        <font size="2" color="#0000FF"><b>Organization:</b></font></td>
        <td width="20" align="left" height="22">&nbsp;</td>
        <th width="487" height="22" align="left"><%= rs5.getString("ORGANISATION")%></th>
      </tr>
      <tr>
        <td width="120" align="right" height="21">
        <font size="2" color="#0000FF"><b>Institution:</b></font></td>
        <td width="20" align="left" height="21">&nbsp;</td>
        <th width="487" height="21" align="left"><%= rs5.getString("INSTITUTION")%></th>
      </tr>
      <tr>
        <td width="120" align="right" height="23">
        <font size="2" color="#0000FF"><b>Position:</b></font></td>
        <td width="20" align="left" height="23">&nbsp;</td>
        <th width="487" height="23" align="left"><%= rs5.getString("JOBFUNCTION")%></th>
      </tr>
      <tr>
        <td width="120" align="right" height="21">
        <font size="2" color="#0000FF"><b>Working Group:</b></font></td>
        <td width="20" align="left" height="21">&nbsp;</td>
        <th width="487" height="21" align="left"><%= rs5.getString("WORKINGGROUP")%></th>
      </tr>
      <%}%>
    </tbody>
    
  </table>
</div>
<p>&nbsp;</p>

</body>

</html>