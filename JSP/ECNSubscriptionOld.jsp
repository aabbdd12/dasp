<%@ page import="java.sql.* , java.io.* ,java.util.*, Mimap.DADUserForm " %> 
<jsp:useBean id="servlet1"  class="Mimap.DADUserForm" />


<head>
<meta name="GENERATOR" content="Microsoft FrontPage 6.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<title>DASP</title>
</head>

<body>

<script>

   function openFirstTimeUserPopup() {
      window.open("ECNPopupFirstTimeUser.html", "", "width=300,height=400,resizable=no,scrollbars=no,status=no,toolbar=no,left=100");
   }

</script>

<%! 
    String emailError;
    String firstnameError;
    String lastnameError;
    String addressError;
    String cityError;
    String institutionError;
    String phoneError;
    %>


<form action="ECNCreateUser.jsp?subscription=1&updatepassword=KO" method="POST" name="myform">





<table cellspacing="0" cellpadding="0" border="0" height="300" width="603" style="border-collapse: collapse" bordercolor="#111111">
  <tr>
    <td class="black" width="601">
      
      
      <table cellspacing="0" cellpadding="0" width="79%" border="0" style="border-collapse: collapse" bordercolor="#111111">
        <span style="font-size: 12.0pt; font-family: Times New Roman">
        <tr>
          <td class="white" valign="top" width="100%">
              <!-- LOGIN INFO START -->
              <!-- LOGIN INFO END --></td>
        </tr>
        <span style="font-size: 12.0pt; ">
        <tr>
          <td class="red" style="background-color: #E4E9FF" width="50%" bgcolor="##006699">
          <font face="Verdana"><b><font color="#000000"><span style="background-color: #E4E9FF">
          <font style="font-size: 9pt">&nbsp;SUBSCRIPTION&nbsp;&nbsp;</font></span></font></b><span style="background-color: #E4E9FF"><font style="font-size: 9pt">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></span></font></td>
        </tr>
        <span style="font-size: 12.0pt; font-family: Times New Roman">
        <tr>
          <td class="white" valign="top" width="100%">
              <!-- PERSONAL INFO START -->
            <table height="339" cellspacing="0" cellpadding="4" width="598" border="0" style="border-collapse: collapse" bordercolor="#111111">
              <tr>
                <td valign="center" align="right" width="582" height="1" style="font-family: arial, helvetica, sans-serif" colspan="2"></td>
              </tr>
              <tr>
                <td valign="center" align="right" width="147" height="22" style="font-family: arial, helvetica, sans-serif">
                <font color="#000080" style="font-size: 9pt">
                <span style="font-family: Verdana">*Title:</span></font></td>
                <td height="22" style="font-family: arial, helvetica, sans-serif" width="435">
                <font style="font-size: 9pt" face="Verdana"><select style="background: #ffffff" name="salutation" size="1">
                    <option>Mr.</option>
                    <option>Miss.</option>
                    <option>Mrs.</option>
                    <option>Prof.</option>
                    <option>Dr.</option>
                    
                  </select></font></td>
              </tr>
              <tr>
                <td valign="center" align="right" height="1" style="font-family: arial, helvetica, sans-serif" width="147">
                <font color="#000080" style="font-size: 9pt">
                <span style="font-family: Verdana">*First
                  Name:</span></font></td>
                <td height="1" style="font-family: arial, helvetica, sans-serif" width="435">
                <font style="font-size: 9pt" face="Verdana"><input maxlength="80" size="30" name="firstname" value></font></td>
              </tr>
              <tr>
                <td align="right" height="22" style="font-family: arial, helvetica, sans-serif" width="147">
                <span style="font-size: 9pt; font-family: Verdana">
                <font color="#000080">*Last
                  Name:</font></span></td>
                <td valign="center" align="right" height="22" style="font-family: arial, helvetica, sans-serif" width="435">
                  <p align="left"><span style="font-family: Verdana">
                  <font style="font-size: 9pt"><input maxlength="80" size="30" name="lastname" value></font></span></td>
              </tr>
              <tr>
        <span style="font-family: Times New Roman">
              <td align="right" height="22" style="font-family: arial, helvetica, sans-serif" width="147">
              <span style="font-family: Verdana"><font color="#000080">
              <span style="font-size: 9pt">Gender</span></font></span></span><span style="font-family: Tahoma; font-size:12.0pt"><span style="font-size: 9pt; font-family: Verdana"><font color="#000080">:</font></span></td>
        <span style="font-size: 12.0pt; font-family: Times New Roman">
              <td height="22" style="font-family: arial, helvetica, sans-serif" width="403">
              <font style="font-size: 9pt"><font face="Verdana"><input type="radio" CHECKED value="M" name="sex"> Male
              </font>
              <input type="radio" value="F" name="sex" style="font-family: Verdana"></font><font face="Verdana"><font size="1" style="font-size: 9pt">
              </font><font style="font-size: 9pt">Female</font></font></td>
                </span></span>
              </tr>
              <tr>
              </span>
            </tr>
            <tr>
              <td valign="center" align="right" height="22" style="font-family: arial, helvetica, sans-serif" width="147">
              <font color="#000080" style="font-size: 9pt">
              <span style="font-family: Verdana">*E-mail
                Address </span></font></td>
              <td height="22" style="font-family: arial, helvetica, sans-serif" width="435">
              <font style="font-size: 9pt" face="Verdana"><input maxlength="80" size="30" name="email" value></font><span style="font-family: Verdana"><font style="font-size: 9pt">
                (no group aliases please)</font></span></td>
            </tr>
            <tr>
              <td valign="center" align="right" height="22" style="font-family: arial, helvetica, sans-serif" width="147">
              <font color="#000080" style="font-size: 9pt">
              <span style="font-family: Verdana">Institution:</span></font></td>
              <td height="22" style="font-family: arial, helvetica, sans-serif" width="435">
              <font style="font-size: 9pt" face="Verdana"><input maxlength="80" size="30" name="institution" value></font></td>
            </tr>
            <tr>
              <td valign="center" align="right" height="22" style="font-family: arial, helvetica, sans-serif" width="147">
              <font color="#000080" style="font-size: 9pt">
              <span style="font-family: Verdana">Street
                Address:</span></font></td>
              <td height="22" style="font-family: arial, helvetica, sans-serif" width="435">
              <font style="font-size: 9pt" face="Verdana"><input maxlength="80" size="45" name="address" value tabindex="3"></font></td>
            </tr>
            <tr>
              <td valign="center" align="right" height="22" style="font-family: arial, helvetica, sans-serif" width="147">
              <font color="#000080"><span class="rednote">
              <font style="font-size: 9pt" face="Verdana">&nbsp;</font></span><span style="font-family: Verdana"><font style="font-size: 9pt">City:</font></span></font></td>
              <td height="22" style="font-family: arial, helvetica, sans-serif" width="435">
              <font style="font-size: 9pt" face="Verdana"><input maxlength="80" size="30" name="city" value></font></td>
            </tr>
            <tr>
              <td valign="center" align="right" height="22" style="font-family: arial, helvetica, sans-serif" width="147">
              <font color="#000080" style="font-size: 9pt">
              <span style="font-family: Verdana">State/Province:</span></font></td>
              <td height="22" style="font-family: arial, helvetica, sans-serif" width="435">
              <font style="font-size: 9pt" face="Verdana"><input maxlength="80" size="30" name="state" value></font></td>
            </tr>
            <tr>
              <td valign="center" align="right" height="22" style="font-family: arial, helvetica, sans-serif" width="147">
              <font color="#000080" style="font-size: 9pt">
              <span style="font-family: Verdana">Postal
                Code:</span></font></td>
              <td height="22" style="font-family: arial, helvetica, sans-serif" width="435">
              <font style="font-size: 9pt" face="Verdana"><input maxlength="80" size="30" name="zip" value></font></td>
            </tr>
            <tr>
              <td valign="center" align="right" height="22" style="font-family: arial, helvetica, sans-serif" width="147">
              <font color="#000080"><span class="rednote">
              <font style="font-size: 9pt" face="Verdana">&nbsp;</font></span><span style="font-family: Verdana"><font style="font-size: 9pt">*Country:</font></span></font></td>
              <td height="22" style="font-family: arial, helvetica, sans-serif" width="435">
              <span style="font-family: Tahoma; font-size:12.0pt">
        <span style="font-size: 12.0pt; font-family: Times New Roman">
              <font style="font-size: 9pt" face="Tahoma">
              <select style="background: #ffffff; font-size:10px; " name="country" size="1">
                  <option value="--Select--">--Select--</option>
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
                  <option value="Bosnia and Herzegovina">Bosnia and Herzegovina</option>
                  <option value="Botswana">Botswana</option>
                  <option value="Bouvet Island">Bouvet Island</option>
                  <option value="Brazil">Brazil</option>
                  <option value="British Indian Ocean Territory">British Indian
                  Ocean Territory</option>
                  <option value="Brunei Darussalam">Brunei Darussalam</option>
                  <option value="Bulgaria">Bulgaria</option>
                  <option value="Burkina Faso">Burkina Faso</option>
                  <option value="Burundi">Burundi</option>
                  <option value="Cambodia">Cambodia</option>
                  <option value="Cameroon">Cameroon</option>
                  <option value="Canada">Canada</option>
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
                  <option value="Congo, Democratic People\'s Republic">Congo,
                  Democratic People's Republic</option>
                  <option value="Congo, Republic of">Congo, Republic of</option>
                  <option value="Cook Islands">Cook Islands</option>
                  <option value="Costa Rica">Costa Rica</option>
                  <option value="Cote d\'Ivoire">Cote d'Ivoire</option>
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
                  <option value="Heard and McDonald Islands">Heard and McDonald
                  Islands</option>
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
                  <option value="Lao People\'s Democratic Republic">Lao People's
                  Democratic Republic</option>
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
                  <option value="Saint Vincent and the Grenadines">Saint Vincent
                  and the Grenadines</option>
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
                  <option value="St Pierre and Miquelon">St Pierre and Miquelon</option>
                  <option value="St. Helena">St. Helena</option>
                  <option value="Suriname">Suriname</option>
                  <option value="Svalbard And Jan Mayen Island">Svalbard And Jan
                  Mayen Island</option>
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
                  <option value="USA">USA</option>
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
                </select></font></td>
            </tr>
            <tr>
              <td valign="center" align="right" height="1" style="font-family: arial, helvetica, sans-serif" width="147">
        <span style="font-size: 12.0pt; font-family: Times New Roman">
              <font color="#000080"><span class="rednote">
              <font style="font-size: 9pt" face="Verdana">&nbsp;</font></span><span style="font-family: Verdana"><font style="font-size: 9pt">Phone
                :</font></span></font></td>
              <td height="1" style="font-family: arial, helvetica, sans-serif" width="435">
        <span style="font-size: 12.0pt; font-family: Times New Roman">
              <font style="font-size: 9pt" face="Verdana"><input maxlength="80" size="30" name="phone" value></font></td>
            </tr>
            <tr>
              <td valign="center" align="right" height="1" style="font-family: arial, helvetica, sans-serif" width="147">
              <font face="Verdana" color="#000080"><span style="font-size: 9pt">
              Comments:</span></font></td>
              <td height="1" style="font-family: arial, helvetica, sans-serif" width="435">
              <textarea rows="5" name="comment" cols="39"></textarea></td>
            </tr>
             
            </table>
<table>
<tr><td>
              
              <INPUT TYPE=CHECKBOX NAME="maillist" checked value="ON">
                  Yes! I want to subscribe to the DASP mailing list 
                  <P>
        </td>     
            </tr>
       
      </table>
        </center>
      </div>
    </td>
  </tr>
  <tr>
    <td style="font-family: arial, helvetica, sans-serif" width="601"><span style="font-size: 12.0pt; font-family: Times New Roman">
      <hr color="#0000FF">
      </span></td>
  </tr>
  <tr>
        <span style="font-size: 12.0pt; font-family: Times New Roman">
                <td valign="center" align="right" width="582" height="16" style="font-family: arial, helvetica, sans-serif">
                  <p align="left"><b>
                  <font face="Verdana" style="font-size: 9pt">Remarks:</font></b></p>
                  <ol style="font-size: 8pt; font-family: Tahoma; color: #000080">
                    <li>
                        <p align="left">
                        <font color="#000080" style="font-size: 9pt" face="Verdana">The &quot;*&quot;
                        Indicates required fields.</font></li>
                    <li>
                        <p align="left">
                        <font color="#000080" style="font-size: 9pt" face="Verdana">Your 
						username/password will be sent to you by e-mail. </font></li>
                    <li>
                        <p align="left">
        <span style="font-size: 12.0pt; ">
                        <font size="2"><span lang="en-ca">The subscribed members 
		are automatically registered in the PEP research network and will 
		receive an email of confirmation.</span></font></span></li>
                  </ol>
                    </td></span>
                
              </tr></span>
  
  <tr>
    <td bordercolor="#CCCCFF" align="left" style="font-family: arial, helvetica, sans-serif" width="601">
      <span style="font-size: 12.0pt; font-family: Times New Roman">
      <hr color="#0000FF">
      </span></td>
  </tr>
  <tr>
    <td bordercolor="#CCCCFF" align="left" style="font-family: arial, helvetica, sans-serif" width="601">
      <p align="center"><b><span style="font-style: italic; background-color: #000000">
      <font style="font-size: 9pt" face="Verdana">
      <input class="buttonblue" onmouseover="this.style.color='#fbe249';" style="border: 1px outset #ccccff; padding-left: 4px; padding-right: 4px; padding-top: 1px; padding-bottom: 1px; background-color: #9999ff; font-weight:bold" onmouseout="this.style.color='#FFF';" type="submit" value="Submit" border="0" name="Submit"></font></span></b></td>
  </tr>
</table>
  </center>
</div>
</form>
<p><span style="font-family: Verdana"><font style="font-size: 9pt">If you have any
question or if you need assistance, please contact:&nbsp;
<a href="MAILTO:aabd@ecn.ulaval.ca">aabd@ecn.ulaval.ca</a>.</font></p>
</span>

</body>