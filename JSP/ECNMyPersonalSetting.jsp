
<%@ page import="java.sql.* , java.io.* ,java.util.*, Mimap.DADUser " %> 
<jsp:useBean id="query3" class="Mimap.DADUser" />


<head>
<meta name="GENERATOR" content="Microsoft FrontPage 5.0" />
<meta name="ProgId" content="FrontPage.Editor.Document" />
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252" />
<title>DAD</title>
<style>
<!--
td{font-family:arial,helvetica,sans-serif;}
.s{font-size:x-small}
-->
</style>
</head>

<body>



<script language="javascript">
function askme(useridvalue){
 
at=document.myform.email.value.indexOf("@");
if(document.myform.address.value ==null || document.myform.address.value.length <1 )
{alert('Address is null !! please fill correctly all fields to receive the CD');}
else if (document.myform.country.value ==null || document.myform.country.value.length <1 )
{alert('Country is null !! please fill correctly all fields to receive the CD ');}
else if (document.myform.state.value ==null || document.myform.state.value.length <1 )
{alert('State is null !! please fill correctly all fields to receive the CD');}
else if (document.myform.city.value ==null || document.myform.city.value.length <1 )
{alert('City is null !! please fill correctly all fields to receive the CD');}
else if (document.myform.firstname.value ==null || document.myform.firstname.value.length <1 )
{alert('Firstname is null !! please fill correctly all fields to receive the CD');}
else if (document.myform.lastname.value ==null || document.myform.lastname.value.length <1 )
{alert('Lastname is null !! please fill correctly all fields to receive the CD');}

else if (at == -1)
	{
	alert("Not a valid e-mail !! please fill correctly all fields to receive the CD")
	}


else
{
  // window.location.href("ECNCreateUser.jsp?userid="+useridvalue);
  result = alert('Thank, CD order confirmed');
 } 
  
}


</script>

<%!          ResultSet rs; 
             String userid;
  %>

  <%
    if (request.getParameter("userid")!=null)
        {
        session.setAttribute("useridtmp",request.getParameter("userid"));
        userid=(String)session.getAttribute("useridtmp");
       // userid=(String)request.getParameter("userid");
        }
    else
        userid=(String)session.getAttribute("userid");
    rs = query3.queryUser2("USERID",userid);

%>

<span style="font-size: 12.0pt; font-family: Times New Roman">
 

  <%!

  String username = "";
  String password = ""; 
  String salutation= "";
  String firstname= "";
  String lastname= "";
  String workinggroup= "";
  String email= "";
  String phone= "";
  String institution= "";
  String organisation= "";
  String position= "";
  String address= "";
  String city= "";
  String state= "";
  String country= "";
  String postalcode= "";
  String email2 = "";
  String phone2= "";
  String fax = "";
  String website= "";
  String cv= "";
%>
<%
  if (rs != null)
    {    
    while (rs.next())
        {
        
         try
         {
         username = rs.getString("USERNAME");
         password = rs.getString("PASSWORD");
         salutation = rs.getString("SALUTATION");
         firstname = rs.getString("FIRSTNAME");
         lastname = rs.getString("LASTNAME");
         email = rs.getString("EMAIL");
         phone = rs.getString("PHONE");
         institution = rs.getString("INSTITUTION");
         address = rs.getString("ADDRESS");
         city = rs.getString("CITY");
         state = rs.getString("STATE");
         country = rs.getString("COUNTRY");
         postalcode = rs.getString("POSTALCODE");
        

         if(username==null)
            username=" ";
         if(password==null)
            password=" ";
         if(firstname==null)
            firstname=" ";
         if(lastname ==null)
            lastname =" ";
         if(email ==null)
            email =" ";
         if(phone ==null)
            phone =" ";
         if(institution ==null)
            institution =" ";
         
         if(organisation ==null)
            organisation =" ";
         if(position ==null)
            position =" ";
         if(address ==null)
            address =" ";
         if(city ==null)
            city =" ";
         if(state ==null)
            state =" ";
         if(country ==null)
            country =" ";
         if(postalcode ==null)
            postalcode =" ";
        

           if(website ==null)
           website =" ";


         }
       catch(Exception e)
       {}

   %>
</span>
  <table cellspacing="1" cellpadding="0" width="67%" border="0">
        <tbody>
        
               
               <span style="font-size: 12.0pt; font-family: Times New Roman">
        <tr>
          <td class="white" valign="top" width="100%">
              <!-- LOGIN INFO START -->
              <!-- LOGIN INFO END --></td>
        </tr>
       <tr>
          <td class="black" style="background-color: #E4E9FF" width="50%" bgcolor="##006699"><b><font color="#000000"><span style="background-color: #E4E9FF">
          &#160;Order DAD CD&#160;</span></font></b><span style="background-color: #E4E9FF">&#160;&#160;&#160;&#160;&#160;&#160;
      </span></td>
        </tr>
        
        
        <tr>
          <td class="white" valign="top" width="100%">
              <!-- PERSONAL INFO START -->
            <table cellspacing="0" cellpadding="4" width="598" border="0" style="border-collapse: collapse" bordercolor="#111111">

             
 			<tbody >

			<form action="ECNCreateUser.jsp?user=<%=userid%>&updatepassword=KO" method="POST" name="myform" >


              <tr>
              
                <td valign="center" align="right" width="174" height="23" style="font-family: arial, helvetica, sans-serif">&#160;</td>
                <td height="23" style="font-family: arial, helvetica, sans-serif" width="408">&#160;</td>
              </tr>
                            <tr>
                <td valign="center" align="right" width="174" height="23" style="font-family: arial, helvetica, sans-serif">
                &#160;</td>
                <td height="23" style="font-family: arial, helvetica, sans-serif" width="408">&#160;</td>
              </tr>
              <tr>
                <td valign="center" align="right" width="174" height="23" style="font-family: arial, helvetica, sans-serif">
                <font color="#0000FF" size="2">
                <span style="font-family: Times New Roman"><b>Title:</b></span></font></td>
                <td height="23" style="font-family: arial, helvetica, sans-serif" width="408"><select style="background: #ffffff" name="salutation" size="1">
                    <span style="font-size: 12.0pt; font-family: Times New Roman">

        
                   
                    <!--option value="<%=salutation%>" selected=""><%=salutation%></option-->
                    <option value="Prof.">Prof.</option>
                    <option value="Dr.">Dr.</option>
                    <option value="Mr.">Mr.</option>
                    <option value="Ms.">Ms.</option>
                    <option value="Miss">Miss</option>
                    <option value="Mrs.">Mrs.</option>
                    </span>
                  </select></td>
              </tr>
              <tr>
                <td valign="center" align="right" height="23" style="font-family: arial, helvetica, sans-serif" width="174">
                <font color="#0000FF" size="2">
                <span style="font-family: Times New Roman"><b>First
                  Name:</b></span></font></td>
                <td height="23" style="font-family: arial, helvetica, sans-serif" width="408"><input maxlength="80" size="30" name="firstname" value="<%=firstname%>"></td>
              </tr>
              <tr>
                <td valign="center" align="right" height="23" style="font-family: arial, helvetica, sans-serif" width="174">
                <span style="font-size: 12.0pt; font-family: Times New Roman">
                <font size="2" color="#0000FF"><b>Last
                  Name:</b></font></span></td>
                <td valign="center" align="right" height="23" style="font-family: arial, helvetica, sans-serif" width="408">
                  </span><p align="left"><span align="left" style="font-size: 12.0pt; font-family: Times New Roman"><span style="font-size: 12.0pt; font-family: Times New Roman"><input maxlength="80" size="30" name="lastname" value="<%=lastname%>" /></span></span></p><span style="font-size: 12.0pt; font-family: Times New Roman"></span></td><span style="font-size: 12.0pt; font-family: Times New Roman">
              </span></tr><span style="font-size: 12.0pt; font-family: Times New Roman">
              
              <tr>
                <td valign="center" align="right" height="23" style="font-family: arial, helvetica, sans-serif" width="174">
                <font color="#0000FF" size="2">
                <span style="font-family: Times New Roman"><b>E-mail
                  Address 1:</b></span></font></td>
                <td height="23" style="font-family: arial, helvetica, sans-serif" width="408"><input maxlength="80" size="30" name="email" value="<%=email%>" /><span style="font-family: Times New Roman"><font size="2">
                  (no group aliases please)</font></span></td>
              </tr>
              
              <tr>
                <td valign="center" align="right" height="23" style="font-family: arial, helvetica, sans-serif" width="174">
                <font color="#0000FF" size="2">
                <span style="font-family: Times New Roman"><b>Institution:</b></span></font></td>
                <td height="21" style="font-family: arial, helvetica, sans-serif" width="408"><input maxlength="80" size="30" name="institution" value="<%=institution%>" /></td>
              </tr>
              
             
              <tr>
                <td valign="center" align="right" height="23" style="font-family: arial, helvetica, sans-serif" width="174">
                <font color="#0000FF" size="2">
                <span style="font-family: Times New Roman"><b>Street
                  Address:</b></span></font></td>
                <td height="23" style="font-family: arial, helvetica, sans-serif" width="408"><input maxlength="80" size="45" name="address" value="<%=address%>" tabindex="3" /></td>
              </tr>
              <tr>
                <td valign="center" align="right" height="23" style="font-family: arial, helvetica, sans-serif" width="174">
                <font color="#0000FF"><span class="rednote"><font size="2">&#160;</font></span><span style="font-family: Times New Roman"><b><font size="2">City:</font></b></span></font></td>
                <td height="23" style="font-family: arial, helvetica, sans-serif" width="408"><input maxlength="80" size="30" name="city" value="<%=city%>" /></td>
              </tr>
              <tr>
                <td valign="center" align="right" height="23" style="font-family: arial, helvetica, sans-serif" width="174">
                <font color="#0000FF" size="2">
                <span style="font-family: Times New Roman"><b>State/Province:</b></span></font></td>
                <td height="23" style="font-family: arial, helvetica, sans-serif" width="408"><input maxlength="80" size="30" name="state" value="<%=state%>" /></td>
              </tr>
              <tr>
                <td valign="center" align="right" height="23" style="font-family: arial, helvetica, sans-serif" width="174">
                <font color="#0000FF" size="2">
                <span style="font-family: Times New Roman"><b>Postal
                  Code:</b></span></font></td>
                <td height="23" style="font-family: arial, helvetica, sans-serif" width="408"><input maxlength="80" size="30" name="zip" value="<%=postalcode%>" /></td>
              </tr>
              <tr>
                <td valign="center" align="right" height="23" style="font-family: arial, helvetica, sans-serif" width="174">
                <font color="#0000FF" size="2">
                <span style="font-family: Times New Roman"><b>*Phone:</b></span></font></td>
                <td height="23" style="font-family: arial, helvetica, sans-serif" width="408">
                <input maxlength="80" size="30" name="phone" value="<%=phone%>" /></td>
              </tr>
              <tr>
                <td valign="center" align="right" height="23" style="font-family: arial, helvetica, sans-serif" width="174">
                <font color="#0000FF"><span class="rednote"><font size="2">&#160;</font></span><span style="font-family: Times New Roman"><b><font size="2">Country:</font></b></span></font></td>
                <td height="23" style="font-family: arial, helvetica, sans-serif" width="408"><select style="background: #ffffff" name="country" size="1">
                    <span style="font-size: 12.0pt; font-family: Times New Roman"><%=country%>
                    <option value="-------------------------------">---------------------------------</option>
                    <option value="United States">United States</option>
                    <option value="Albania">Albania</option>
                    <option value="Algeria">Algeria</option>
                    <option value="American Samoa">American Samoa</option>
                    <option value="Andorra">Andorra</option>
                    <option value="Angola">Angola</option>
                    <option value="Anguilla">Anguilla</option>
                    <option value="Antartica">Antartica</option>
                    <option value="Antigua &amp; Barbuda">Antigua &amp; Barbuda</option>
                    <option value="Argentina">Argentina</option>
                    <option value="Armenia">Armenia</option>
                    <option value="Aruba">Aruba</option>
                    <option value="Ascension Island">Ascension Island</option>
                    <option value="Australia">Australia</option>
                    <option value="Austria">Austria</option>
                    <option value="Azerbaijan">Azerbaijan</option>
                    <option value="Bahamas">Bahamas</option>
                    <option value="Bahrain">Bahrain</option>
                    <option value="Bangladesh">Bangladesh</option>
                    <option value="Barbados">Barbados</option>
                    <option value="Belarus">Belarus</option>
                    <option value="Belgium">Belgium</option>
                    <option value="Belize">Belize</option>
                    <option value="Benin">Benin</option>
                    <option value="Bermuda">Bermuda</option>
                    <option value="Bhutan">Bhutan</option>
                    <option value="Bolivia">Bolivia</option>
                    <option value="Bosnia and Herzegovina">Bosnia and
                    Herzegovina</option>
                    <option value="Botswana">Botswana</option>
                    <option value="Bouvet Island">Bouvet Island</option>
                    <option value="Brazil">Brazil</option>
                    <option value="British Indian Ocean Territory">British
                    Indian Ocean Territory</option>
                    <option value="Brunei Darussalam">Brunei Darussalam</option>
                    <option value="Bulgaria">Bulgaria</option>
                    <option value="Burkina Faso">Burkina Faso</option>
                    <option value="Burundi">Burundi</option>
                    <option value="Cambodia">Cambodia</option>
                    <option value="Cameroon">Cameroon</option>
                    <option value="Canada" selected="">Canada</option>
                    <option value="Cape Verde">Cape Verde</option>
                    <option value="Cayman Islands">Cayman Islands</option>
                    <option value="Central African Republic">Central African
                    Republic</option>
                    <option value="Chad">Chad</option>
                    <option value="Chile">Chile</option>
                    <option value="China">China</option>
                    <option value="Christmas Island">Christmas Island</option>
                    <option value="Cocos (Keeling) Islands">Cocos (Keeling)
                    Islands</option>
                    <option value="Colombia">Colombia</option>
                    <option value="Comoros">Comoros</option>
                    <option value="Congo, Democratic People's Republic">Congo,
                    Democratic People&apos;s Republic</option>
                    <option value="Congo, Republic of">Congo, Republic of</option>
                    <option value="Cook Islands">Cook Islands</option>
                    <option value="Costa Rica">Costa Rica</option>
                    <option value="Cote d'Ivoire">Cote d&apos;Ivoire</option>
                    <option value="Croatia/Hrvatska">Croatia/Hrvatska</option>
                    <option value="Cyprus">Cyprus</option>
                    <option value="Czech Republic">Czech Republic</option>
                    <option value="Denmark">Denmark</option>
                    <option value="Djibouti">Djibouti</option>
                    <option value="Dominica">Dominica</option>
                    <option value="Dominican Republic">Dominican Republic</option>
                    <option value="East Timor">East Timor</option>
                    <option value="Ecuador">Ecuador</option>
                    <option value="Egypt">Egypt</option>
                    <option value="El Salvador">El Salvador</option>
                    <option value="Equatorial Guinea">Equatorial Guinea</option>
                    <option value="Eritrea">Eritrea</option>
                    <option value="Estonia">Estonia</option>
                    <option value="Ethiopia">Ethiopia</option>
                    <option value="Falkland Islands (Malvina)">Falkland Islands
                    (Malvina)</option>
                    <option value="Faroe Islands">Faroe Islands</option>
                    <option value="Fiji">Fiji</option>
                    <option value="Finland">Finland</option>
                    <option value="France">France</option>
                    <option value="French Guiana">French Guiana</option>
                    <option value="French Polynesia">French Polynesia</option>
                    <option value="French Southern Territories">French Southern
                    Territories</option>
                    <option value="Gabon">Gabon</option>
                    <option value="Gambia">Gambia</option>
                    <option value="Georgia">Georgia</option>
                    <option value="Germany">Germany</option>
                    <option value="Ghana">Ghana</option>
                    <option value="Gibraltar">Gibraltar</option>
                    <option value="Great Britain">Great Britain</option>
                    <option value="Greece">Greece</option>
                    <option value="Greenland">Greenland</option>
                    <option value="Grenada">Grenada</option>
                    <option value="Guadeloupe">Guadeloupe</option>
                    <option value="Guam">Guam</option>
                    <option value="Guatemala">Guatemala</option>
                    <option value="Guernsey">Guernsey</option>
                    <option value="Guinea">Guinea</option>
                    <option value="Guinea-Bissau">Guinea-Bissau</option>
                    <option value="Guyana">Guyana</option>
                    <option value="Haiti">Haiti</option>
                    <option value="Heard and McDonald Islands">Heard and
                    McDonald Islands</option>
                    <option value="Holy See (City Vatican State)">Holy See (City
                    Vatican State)</option>
                    <option value="Honduras">Honduras</option>
                    <option value="Hong Kong">Hong Kong</option>
                    <option value="Hungary">Hungary</option>
                    <option value="Iceland">Iceland</option>
                    <option value="India">India</option>
                    <option value="Indonesia">Indonesia</option>
                    <option value="Ireland">Ireland</option>
                    <option value="Isle of Man">Isle of Man</option>
                    <option value="Israel">Israel</option>
                    <option value="Italy">Italy</option>
                    <option value="Jamaica">Jamaica</option>
                    <option value="Japan">Japan</option>
                    <option value="Jersey">Jersey</option>
                    <option value="Jordan">Jordan</option>
                    <option value="Kazakhstan">Kazakhstan</option>
                    <option value="Kenya">Kenya</option>
                    <option value="Kiribati">Kiribati</option>
                    <option value="Korea, Republic of">Korea, Republic of</option>
                    <option value="Kuwait">Kuwait</option>
                    <option value="Kyrgyzstan">Kyrgyzstan</option>
                    <option value="Lao People's Democratic Republic">Lao
                    People&apos;s Democratic Republic</option>
                    <option value="Latvia">Latvia</option>
                    <option value="Lebanon">Lebanon</option>
                    <option value="Lesotho">Lesotho</option>
                    <option value="Liberia">Liberia</option>
                    <option value="Liechtenstein">Liechtenstein</option>
                    <option value="Lithuania">Lithuania</option>
                    <option value="Luxembourg">Luxembourg</option>
                    <option value="Macau">Macau</option>
                    <option value="Macedonia, Former Yugoslav Republic">Macedonia,
                    Former Yugoslav Republic</option>
                    <option value="Madagascar">Madagascar</option>
                    <option value="Malawi">Malawi</option>
                    <option value="Malaysia">Malaysia</option>
                    <option value="Maldives">Maldives</option>
                    <option value="Mali">Mali</option>
                    <option value="Malta">Malta</option>
                    <option value="Marshall Islands">Marshall Islands</option>
                    <option value="Martinique">Martinique</option>
                    <option value="Mauritania">Mauritania</option>
                    <option value="Mauritius">Mauritius</option>
                    <option value="Mayotte">Mayotte</option>
                    <option value="Mexico">Mexico</option>
                    <option value="Micronesia, Federal State of">Micronesia,
                    Federal State of</option>
                    <option value="Moldova, Republic of">Moldova, Republic of</option>
                    <option value="Monaco">Monaco</option>
                    <option value="Mongolia">Mongolia</option>
                    <option value="Montserrat">Montserrat</option>
                    <option value="Morocco">Morocco</option>
                    <option value="Mozambique">Mozambique</option>
                    <option value="Namibia">Namibia</option>
                    <option value="Nauru">Nauru</option>
                    <option value="Nepal">Nepal</option>
                    <option value="Netherlands">Netherlands</option>
                    <option value="Netherlands Antilles">Netherlands Antilles</option>
                    <option value="New Caledonia">New Caledonia</option>
                    <option value="New Zealand">New Zealand</option>
                    <option value="Nicaragua">Nicaragua</option>
                    <option value="Niger">Niger</option>
                    <option value="Nigeria">Nigeria</option>
                    <option value="Niue">Niue</option>
                    <option value="Norfolk Island">Norfolk Island</option>
                    <option value="Northern Mariana Island">Northern Mariana
                    Island</option>
                    <option value="Norway">Norway</option>
                    <option value="Oman">Oman</option>
                    <option value="Pakistan">Pakistan</option>
                    <option value="Palau">Palau</option>
                    <option value="Panama">Panama</option>
                    <option value="Papua New Guinea">Papua New Guinea</option>
                    <option value="Paraguay">Paraguay</option>
                    <option value="Peru">Peru</option>
                    <option value="Philippines">Philippines</option>
                    <option value="Pitcairn Island">Pitcairn Island</option>
                    <option value="Poland">Poland</option>
                    <option value="Portugal">Portugal</option>
                    <option value="Puerto Rico">Puerto Rico</option>
                    <option value="Qatar">Qatar</option>
                    <option value="Reunion Island">Reunion Island</option>
                    <option value="Romania">Romania</option>
                    <option value="Russian Federation">Russian Federation</option>
                    <option value="Rwanda">Rwanda</option>
                    <option value="Saint Kitts and Nevis">Saint Kitts and Nevis</option>
                    <option value="Saint Lucia">Saint Lucia</option>
                    <option value="Saint Vincent and the Grenadines">Saint
                    Vincent and the Grenadines</option>
                    <option value="San Marino">San Marino</option>
                    <option value="Sao Tome &amp; Principe">Sao Tome &amp;
                    Principe</option>
                    <option value="Saudi Arabia">Saudi Arabia</option>
                    <option value="Senegal">Senegal</option>
                    <option value="Seychelles">Seychelles</option>
                    <option value="Sierra Leone">Sierra Leone</option>
                    <option value="Singapore">Singapore</option>
                    <option value="Slovak Republic">Slovak Republic</option>
                    <option value="Slovenia">Slovenia</option>
                    <option value="Solomon Islands">Solomon Islands</option>
                    <option value="Somalia">Somalia</option>
                    <option value="South Africa">South Africa</option>
                    <option value="South Georgia and the South Sandwich Islands">South
                    Georgia and the South Sandwich Islands</option>
                    <option value="Spain">Spain</option>
                    <option value="Sri Lanka">Sri Lanka</option>
                    <option value="St Pierre and Miquelon">St Pierre and
                    Miquelon</option>
                    <option value="St. Helena">St. Helena</option>
                    <option value="Suriname">Suriname</option>
                    <option value="Svalbard And Jan Mayen Island">Svalbard And
                    Jan Mayen Island</option>
                    <option value="Swaziland">Swaziland</option>
                    <option value="Sweden">Sweden</option>
                    <option value="Switzerland">Switzerland</option>
                    <option value="Taiwan">Taiwan</option>
                    <option value="Tajikistan">Tajikistan</option>
                    <option value="Tanzania">Tanzania</option>
                    <option value="Thailand">Thailand</option>
                    <option value="Togo">Togo</option>
                    <option value="Tokelau">Tokelau</option>
                    <option value="Tonga">Tonga</option>
                    <option value="Trinidad and Tobago">Trinidad and Tobago</option>
                    <option value="Tunisia">Tunisia</option>
                    <option value="Turkey">Turkey</option>
                    <option value="Turkmenistan">Turkmenistan</option>
                    <option value="Turks and Ciacos Islands">Turks and Ciacos
                    Islands</option>
                    <option value="Tuvalu">Tuvalu</option>
                    <option value="US Minor Outlying Islands">US Minor Outlying
                    Islands</option>
                    <option value="Uganda">Uganda</option>
                    <option value="Ukraine">Ukraine</option>
                    <option value="United Arab Emirates">United Arab Emirates</option>
                    <option value="United Kingdom">United Kingdom</option>
                    <option value="Uruguay">Uruguay</option>
                    <option value="Uzbekistan">Uzbekistan</option>
                    <option value="Vanuatu">Vanuatu</option>
                    <option value="Venezuela">Venezuela</option>
                    <option value="Vietnam">Vietnam</option>
                    <option value="Virgin Island (British)">Virgin Island
                    (British)</option>
                    <option value="Virgin Islands (USA)">Virgin Islands (USA)</option>
                    <option value="Wallis And Futuna Islands">Wallis And Futuna
                    Islands</option>
                    <option value="Western Sahara">Western Sahara</option>
                    <option value="Western Samoa">Western Samoa</option>
                    <option value="Yemen">Yemen</option>
                    <option value="Yugoslavia">Yugoslavia</option>
                    <option value="Zambia">Zambia</option>
                    <option value="Zimbabwe">Zimbabwe</option>
                    </span>
                  </select></td>
              </tr>
            
              <tr>
                <td valign="center" align="right" height="23" style="font-family: arial, helvetica, sans-serif" width="174">
                &#160;</td>
                <td height="23" style="font-family: arial, helvetica, sans-serif" width="408">&#160;</td>
              </tr>
              <tr>
                <td valign="center" align="right" height="23" style="font-family: arial, helvetica, sans-serif" width="174">
                &#160;</td>
                <td height="23" style="font-family: arial, helvetica, sans-serif" width="408">
        <span style="font-size: 12.0pt; font-family: Times New Roman">
                <b><span style="font-style: italic; background-color: #000000">
                <input class="buttonblue" onmouseover="this.style.color='#fbe249';" style="border: 1px outset #ccccff; padding-left: 4px; padding-right: 4px; padding-top: 1px; padding-bottom: 1px; background-color: #9999ff; font-size:8pt; font-weight:bold" onmouseout="this.style.color='#FFF';" type="submit" onClick="askme(<%=userid%>)" value="Order CD Now" border="0" name="UpdateButtonId_1" /></span></b></span></td>
              </tr>
              <tr>
                <td valign="center" align="right" height="23" style="font-family: arial, helvetica, sans-serif" width="174">
                &#160;</td>
                <td height="23" style="font-family: arial, helvetica, sans-serif" width="408">&#160;</td>
              </tr>
              <tr>
                <td valign="center" align="right" height="23" style="font-family: arial, helvetica, sans-serif" width="174">
                &#160;</td>
                <td height="23" style="font-family: arial, helvetica, sans-serif" width="408">&#160;</td>
              </tr>
            </span></tbody><span style="font-size: 12.0pt; font-family: Times New Roman">
            </span><span style="font-size: 12.0pt; font-family: Times New Roman">
            </span></table><span style="font-size: 12.0pt; font-family: Times New Roman">
          </span></td><span style="font-size: 12.0pt; font-family: Times New Roman">
        </span></tr><span style="font-size: 12.0pt; font-family: Times New Roman">
        </span></tbody><span style="font-size: 12.0pt; font-family: Times New Roman">
        </span></table><span style="font-size: 12.0pt; font-family: Times New Roman">
      </span></td>
  </tr>
   
</form>

</table>
<%}}%>

<p><span style="font-size: 12.0pt; font-family: Times New Roman">If you have any
question or if you need assistance, please contact:&#160;
<a href="MAILTO:pep@ecn.ulaval.ca">pep@ecn.ulaval.ca</a>.</span></p><span style="font-size: 12.0pt; font-family: Times New Roman">
</span>

</body>