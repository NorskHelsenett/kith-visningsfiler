<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:hmt="http://www.kith.no/xmlstds/medtjenhdr/2008-23-05" 
	xmlns:lso="http://www.kith.no/xmlstds/rekvisisjon/2005-05-20" 
	xmlns="http://www.w3.org/1999/xhtml" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	exclude-result-prefixes="hmt lso xhtml">

	<!--
FORMÅL
XSLT for generering av html for Rekvisisjon Patologi v.1.4

ENDRINGER:
13.08.2008: Første

TODO/Svakheter:

* Skal det være lso eller lsr som prefiks?
* Type undersøkelse er angitt som både MsgDescr og under ReqInvestiation/Investigation. I visningsfilen for rekvisisjonen vises begge disse to feltene.
* I kasuistikk 4 er det to AnalysedSubject. Dette fungerer fint for rekvisisjonen, men dette er ikke tatt hensyn til at det kan være flere AnalysedSubject i visningsfilen for svarrapporten
* De mest relevante Comment-felter er tatt med. Men mange av comment-feltene i UML-modellen behandles ikke i denne visningsfilen.
* InfItem(Klinisk opplysninger) under Patient er ikke tatt med (mer aktuelt for radiologi)
* Benytter skriveformene CollectorComment (entall), CollectorsCommentCoded (flertall) og SubjectMeasures (flertall) som definert i "XML meldingsbeskrivelse for rekvirering"

-->

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" 
		doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

	<xsl:include href="header_medisinske_tjenester.xsl"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>Rekvisisjon Patologi</title>
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
			<b>Rekvisisjonsdato: </b>
			<xsl:value-of select="lso:IssueDate/@V"/>
			<br/>
			<b>Id til rekvisisjonen:&#160;</b>
			<xsl:value-of select="lso:Id"/>
			<br/>
			<xsl:if test="lso:PaymentCat">
				<b>Debitor:&#160;</b>
				<xsl:value-of select="lso:PaymentCat/@DN"/>
				<br/>
			</xsl:if>
			<br/>
			<b>Kliniske opplysninger:</b>
			<br/>
			<xsl:for-each select="//lso:RefDoc">
				<xsl:value-of select="lso:MsgType/@DN"/>:&#160;<xsl:value-of select="lso:Id"/>
				<br/>
			</xsl:for-each>
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
			<b>Ønskede undersøkelser:</b>
			<br/>
			<xsl:value-of select="lso:MsgDescr/@DN"/>
			<br/>
			<xsl:for-each select="lso:ReqInvestigation/lso:Investigation">
			- <xsl:value-of select="lso:Id/@DN"/> (<xsl:value-of select="lso:Id/@V"/>)<br/>
			</xsl:for-each>
		</div>
		<div class="Document">
			<b>Prøvemateriale</b>
			<br/>
			<xsl:for-each select="lso:ReqInvestigation/lso:AnalysedSubject">


				Prøveid:&#160;<xsl:value-of select="lso:IdByRequester"/>
				<br/>
           Prøve tatt:&#160; <xsl:value-of select="lso:CollectedSample/lso:CollectedDate/@V"/>
				<br/>
				<xsl:if test="lso:TypeCoded">
						Prøvetype:&#160;<xsl:value-of select="lso:TypeCoded/@DN"/>
					<br/>
				</xsl:if>
				<xsl:if test="lso:Type">
							Prøvetype:&#160;<xsl:value-of select="lso:Type"/>
					<br/>
				</xsl:if>
				<xsl:if test="lso:Number">
							Antall prøver:&#160;<xsl:value-of select="lso:Number"/>
					<br/>
				</xsl:if>
				<xsl:if test="lso:AnatomicalOrigin">
						Anatomisk lokasjon:&#160;<xsl:value-of select="lso:AnatomicalOrigin"/>
					<br/>
				</xsl:if>
				<xsl:if test="lso:PreservMaterial">
Konserveringsmiddel:&#160;<xsl:value-of select="lso:PreservMaterial"/>
					<br/>
				</xsl:if>
				<xsl:if test="lso:SampleCollProc">
						Prøvetakingsprosedyre:&#160;<xsl:value-of select="lso:SampleCollProc/@DN"/>
					<br/>
				</xsl:if>
				<xsl:if test="lso:SubjectMeasures">
					<xsl:value-of select="lso:SubjectMeasures/lso:TypeQuantity"/>:&#160;<xsl:value-of select="lso:SubjectMeasures/lso:Quantity/@V"/>&#160;<xsl:value-of select="lso:SubjectMeasures/lso:Quantity/@U"/>
					<br/>
				</xsl:if>
				<xsl:if test="lso:CollectedSample/lso:CollectorsCommentCoded">
Cytologisk prøve tatt med:&#160; <xsl:value-of select="lso:CollectedSample/lso:CollectorsCommentCoded/@DN"/>
					<br/>
				</xsl:if>
				<xsl:if test="lso:CollectedSample/lso:CollectorComment">
<xsl:value-of select="lso:CollectedSample/lso:CollectorComment"/>
					<br/>
				</xsl:if>

				<xsl:if test="lso:Comment">
Kommentar til tatt prøve:&#160; <xsl:value-of select="lso:Comment"/>
					<br/>
				</xsl:if>
				<br/>
			</xsl:for-each>
			<xsl:for-each select="lso:Patient/lso:InfItem">
				<xsl:value-of select="./lso:Observation/lso:CodedDescr/@DN"/>&#160;<xsl:value-of select="./lso:StartDateTime/@V"/>
			</xsl:for-each>
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
