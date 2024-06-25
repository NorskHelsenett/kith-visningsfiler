<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
	xmlns:lso="http://www.kith.no/xmlstds/rekvisisjon/2005-05-20" 
	xmlns="http://www.w3.org/1999/xhtml" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	exclude-result-prefixes="lso xhtml">
	
	<!--
FORMÅL
XSLT for generering av html fra Svarrapport Medisinske Tjenester - Mikrobiologi v.1.0

ENDRINGER:
06.05.2008: Andre versjon etter forslag sendt inn 28.04

TODO/Svakheter:
*Det ligger ikke element som angir adresse til <Inst>
*I eksemplet skal det angis avdeling vs seksjon. Hvor er det angitt i xml-fil?
*Her tatt utgangspunkt i <Patient>, skal man lage en hvor man tester på pasient vs dyr, legge inn for <Animal>?
*Hvilket element inneholder Prøve mottatt?
*For svar, brukt "referanseområde" istedet for "normalområde", det er mer korrekt.
*Kan det være flere <AnalysedSubject> i hver xml-fil? -hva linker i så fall hvilken ResultItem til hvilken AnalysedSubject?
*Endret prøve tatt fra issueDate til CollectedDate i prøveheader

*OBS! CAVE-informasjon må være med, dvs modde casefil!
-->

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" 
		doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

	<xsl:include href="header_medisinske_tjenester.xsl"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>Rekvisisjon Biokjemi</title>
				<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
				<style type="text/css">
					
.Header
{
width: 95%;
margin: 1px;
border:1px solid gray;
padding:1em;
background-color: #ffffff;
font-family: arial;
font-size: 0.8em;
height: 24.5em;
}
.Patient,.ServProvider,.Requester, .CopyDest 
{
width: 45%;
height: 10em;
float: left;
border: solid black 1px;
padding: 0.5em;
margin: 0.5em;
}
.Request
{
width: 95%;
float: left;
border: solid black 1px;

padding: 0.5em;

}
.Document
{
width:95%;
clear:left;
margin: 20px 1px 1px 1px;
border:1px solid gray;
padding:1em;
background-color: #ffffff;
font-family: arial;
font-size: 0.8em;
}


.Document h1
{
padding:0.3em;
color:white;
background-color:gray;
border:1px solid gray;
font: 1.5em;
line-height:0.7em;
margin-bottom:0.3em;
}

.Document h2
{
padding:0.5em;
color:white;
background-color: gray;
border:1px solid gray;
font-size: 1.1em;
line-height:0.7em;
margin-bottom:0.3em;
}

.Document h3
{
padding:0.5em;
color:black;
font-size: 1em;
line-height:0.7em;
margin-bottom:0.3em
}

table.Default
{
width:95%;
border:1px solid black;
}



.Document th
{
background-color: #CAE8EA;
border-style:none;
font-family:Arial;
font-size:12px;
text-align: left;
text-valign: top;
}

.Document td
{

background-color: white;
border-style: none;
text-align: left;
font-size: 12px;
}
td.CellBorder
{
background-color:#FFFFFF;
border:1px solid gray;
}
table.Noborder
{
background-color:#FFFFFF;
width:95%
border:0;
}

th.Noborder
{
background-color:#FFFFFF;
border-style:none;
font-family:Arial;
font-size:12px;
text-align: left;
text-valign: top;
}

td.Noborder
{
background-color:#FFFFFF;
border-style: none;
text-align: left;
font-size: 12px;
}

td.Emphasized
{
background-color:#CAE8EA;
border:1px solid gray;
}


.Document p
{
margin-top:0.5em;
}
.TableFormHeader
{ 
background-color: #fff2ba;
text-align: left;
font-family: Arial;
border-style: none;
font-weight: bold;
font-size: 12px;
}

.DocumentFooter
{
padding:0.5em;
color:black;
background-color: #dddddd;
border:1px solid black;
font-size: 10px;
margin:0.5em;
}
	</style>
			</head>
			<body>
				<xsl:apply-templates/>
			</body>
		</html>
	</xsl:template>
	<!--Start på rekvisisjonsbolk -->
	<xsl:template name="RequestBody">
		<div class="Document">
			<b>Utstedelsestidspunkt:</b>&#160;<xsl:value-of select="./lso:IssueDate/@V"/>
			<br/><b>Id til rekvisisjonen:</b>&#160;<xsl:value-of select="lso:Id"/>
			<xsl:if test="lso:PaymentCat">
				<br/>
				<b>Betalingskategori</b>&#160;</xsl:if>
			<xsl:value-of select="lso:PaymentCat/@DN"/>
			<xsl:if test="//lso:CodedComment or //lso:ReqComment">
				<br/>
				<b>Kommentarer til rekvisisjonen:&#160;</b>
				<xsl:value-of select="lso:ReqComment"/>
				<xsl:for-each select="//lso:CodedComment">
					<xsl:value-of select="lso:CodedComment"/>
				</xsl:for-each>
			</xsl:if>
		</div>
		<div class="Document">
			<b>Kliniske opplysninger:</b>
			<br/>
			<xsl:for-each select="//lso:ReasonAsText">
				<xsl:if test="lso:Heading">
					<xsl:value-of select="lso:Heading/@V"/>&#160;<xsl:value-of select="lso:Heading/@DN"/>
					<br/>
				</xsl:if>
				<xsl:if test="lso:TextResultValue">
					<xsl:value-of select="lso:TextResultValue"/>
					<br/>
				</xsl:if>
				<xsl:if test="lso:TextCode">
					<xsl:value-of select="lso:TextCode/@V"/> &#160; <xsl:value-of select="lso:TextCode/@DN"/>
					<br/>
				</xsl:if>
			</xsl:for-each>
		</div>
		<div class="Document">
			<b>Prøver:</b>
			<br/>
			<xsl:for-each select="//lso:ReqInvestigation">
				<br/><b>Status</b>&#160;<xsl:value-of select="./lso:ServType/@DN"/>
				
				<xsl:if test="./lso:Purpose">
					<br/><b>Formål med undersøkelsen:</b>&#160;<xsl:value-of select="./lso:Purpose/@DN"/>
				</xsl:if>
				<xsl:if test="./lso:Priority">
					<br/><b>Hastegrad for rekvisisjonen:&#160;</b><xsl:value-of select="./lso:Priority/@V"/>&#160;<xsl:value-of select="./lso:Priority/@DN"/>
				</xsl:if>
				
				<xsl:for-each select="lso:AnalysedSubject">
					
					<xsl:if test="lso:CollectedSample">
						<br/><b>Prøvetidspunkt:&#160;</b>
						<xsl:value-of select="./lso:CollectedSample/lso:CollectedDate/@V"/>&#160;
						<xsl:value-of select="./lso:CollectedSample/lso:CollectorComment"/>
						<xsl:for-each select="./lso:CollectedSample/lso:CollectorsCommentCoded">
							&#160;<xsl:value-of select="./@V"/>&#160;<xsl:value-of select="./@DN"/>
						</xsl:for-each>
					</xsl:if>	
					<br/><b>Prøvemateriale:&#160;</b><xsl:apply-templates select="./lso:Type"/>&#160;<xsl:apply-templates select="./lso:TypeCoded/@V"/>&#160;<xsl:apply-templates select="./lso:TypeCoded/@DN"/>
					<xsl:if test="./lso:IdByRequester"><br/><b>Rekvirentens prøveid:&#160;</b><xsl:value-of select="./lso:IdByRequester"/></xsl:if>
					<xsl:if test="./lso:RequestedSubject">
						<br/><b>Hastegrad for prøven:&#160;</b><xsl:value-of select="./lso:RequestedSubject/lso:Priority/@V"/>&#160;<xsl:value-of select="./lso:RequestedSubject/lso:Priority/@DN"/>
						<br/><b>Rekvisisjonsdato:&#160;</b>
						<xsl:value-of select="./lso:RequestedSubject/lso:ReqDate/@V"/>
					</xsl:if>
					<xsl:if test="./lso:SubjectMeasures"><br/><b>Prøvens mål:&#160;</b><xsl:value-of select="./lso:SubjectMeasures/lso:TypeQuantity"/>&#160;<xsl:value-of select="./lso:SubjectMeasures/lso:Quantity/@V"/>&#160;<xsl:value-of select="./lso:SubjectMeasures/lso:Quantity/@U"/></xsl:if>
					
					<xsl:if test="./lso:PreservMaterial"><br/><b>Konserveringsmiddel:&#160;</b><xsl:value-of select="./lso:PreservMaterial"/></xsl:if>
					<xsl:if test="./lso:Comment"><br/><b>Rekvirentens kommentar til prøven:&#160;</b><xsl:value-of select="./lso:Comment"/></xsl:if>
					<xsl:if test="./lso:AnatomicalOrigin"><br/><b>Lokalisasjon:&#160;</b><xsl:value-of select="./lso:AnatomicalOrigin"/></xsl:if>
					<xsl:if test="./lso:Number"><br/><b>Antall:&#160;</b><xsl:value-of select="./lso:Number"/></xsl:if>
				</xsl:for-each>
				<br/>
				<xsl:for-each select="lso:Investigation">
					<br/><b>Analyse:&#160;</b><xsl:value-of select="./lso:Id/@V"/>&#160;<xsl:value-of select="./lso:Id/@DN"/><br/>
				</xsl:for-each>
				
				<xsl:if test="lso:Comment">
					<xsl:value-of select="lso:Comment/lso:Heading/@DN"/>
					<xsl:value-of select="lso:Comment/lso:TextResultValue"/>
					<xsl:value-of select="lso:Comment/lso:Textcode/@DN"/>
					<br/>
				</xsl:if>
			</xsl:for-each>
		</div>
		<div class="Document">
			<b>Nødvendige opplysninger og kontraindikasjoner:</b>
			<table>
			
			
			
				<xsl:if test="//lso:SampleHandling">
					<tr><td><b>Prøvehåndtering:&#160;</b></td>
					<td><xsl:for-each select="//lso:SampleHandling">
						<xsl:value-of select="."/>,&#160;
					</xsl:for-each></td>
					</tr>
				</xsl:if>
				<xsl:for-each select="//lso:InfItem">
					<tr>
						<td>
							<b><xsl:apply-templates select="./lso:Type/@V"/>&#160;<xsl:apply-templates select="./lso:Type/@DN"/>:&#160;</b>
						</td>
							<xsl:if test="./lso:Observation">	
							<td>
								<xsl:value-of select="./lso:Observation/lso:Description"/>
						
									<xsl:value-of select="lso:Observation/lso:CodedDescr/@V"/>&#160;<xsl:value-of select="lso:Observation/lso:CodedDescr/@DN"/>
								</td>
							</xsl:if>
					
					</tr>
				</xsl:for-each>
			</table>
			<!--ikke glem å vurdere om det er tatt med dette med kreatininnivå ved kontrastundersøkelser-->
		</div>
	</xsl:template>
	<!-- Slutt på svarbolk -->
	<xsl:template match="lso:Message">
		<!-- utelater meldingsid og kommunikasjonsinformasjon -->
		<xsl:apply-templates select="lso:ServReq"/>
	</xsl:template>
	<!-- Hoveddel dokument -->
	<xsl:template match="lso:ServReq">
		<xsl:call-template name="Header"/>
		<!--kaller opp rekvisisjonsbolk-->
		<xsl:call-template name="RequestBody"/>
	</xsl:template>
	<!-- Slutt på hoveddel dokument -->
</xsl:stylesheet>
