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
XSLT for generering av html fra Svarrapport Medisinske Tjenester - Mikrobiologi v.1.0

ENDRINGER:
21.02.2017: Endret html-tittel
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
				<title>Rekvisisjon Radiologi</title>
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
		<xsl:if test="lso:PaymentCat"><br/><b>Betalingskategori</b>&#160;</xsl:if><xsl:value-of select="lso:PaymentCat/@DN"/>
		<xsl:if test="//lso:CodedComment"><b>Kommentarer til rekvisisjonen:</b>
			<xsl:for-each select="//lso:CodedComment">
				<xsl:value-of select="lso:CodedComment"/>
			</xsl:for-each>
		</xsl:if>
	</div>
		<div class="Document">
			<table>
				<tbody>
					<tr>
						<td>1</td><td>Jeg ber om at radiologen endrer modalitet (undersøkelsesmetode) og eventuelt foretar supplerende undersøkelser hvor dette er medisinsk indisert &#160;</td><td class="CellBorder">&#160;<xsl:if test="./lso:Comment/lso:TextCode/@V='1'"><b>X</b></xsl:if>&#160;</td>
					</tr>
					<tr>
						<td>2</td><td>Jeg kan ikke anbefale at radiologen endrer modalitet (undersøkelsesmetode) og eventuelt foretar supplerende undersøkelser</td><td class="CellBorder">&#160;<xsl:if test="./lso:Comment/lso:TextCode/@V='2'"><b>X</b></xsl:if>&#160;</td>
					</tr>
				</tbody>
			</table>
		</div>
		<div class="Document">	
			<b>Kliniske opplysninger:</b><br/> 
			<xsl:for-each select="//lso:ReasonAsText">
				<xsl:if test="lso:Heading"><xsl:value-of select="lso:Heading/@V"/>&#160;<xsl:value-of select="lso:Heading/@DN"/><br/></xsl:if>
				<xsl:if test="lso:TextResultValue"><xsl:value-of select="lso:TextResultValue"/><br/></xsl:if>
				<xsl:if test="lso:TextCode"><xsl:value-of select="lso:TextCode/@V"/> &#160; <xsl:value-of select="lso:TextCode/@DN"/><br/></xsl:if>
			</xsl:for-each>

			
		</div>
		<div class="Document">
			<b>Hva ønskes undersøkt?</b><br/>
			<xsl:for-each select="//lso:ReqInvestigation">
				<br/><b><xsl:value-of select="./lso:Investigation/lso:Id/@V"/></b><xsl:value-of select="./lso:Investigation/lso:Id/@OT"/>&#160;<xsl:value-of select="./lso:Investigation/lso:Id/@DN"/>&#160;<b><xsl:value-of select="./lso:ServType/@DN"/></b>&#160;<xsl:value-of select="lso:Purpose/@DN"/><br/>
				<xsl:if test="lso:Priority">Hastegrad: <xsl:value-of select="lso:Priority/@V"/>&#160;<xsl:value-of select="lso:Priority/@DN"/><br/></xsl:if>
				<xsl:if test="lso:Comment"><xsl:value-of select="lso:Comment/lso:Heading/@DN"/><xsl:value-of select="lso:Comment/lso:TextResultValue"/><xsl:value-of select="lso:Comment/lso:Textcode/@DN"/><br/></xsl:if>
			</xsl:for-each>

		</div>
		<div class="Document">
		<b>Nødvendige opplysninger og kontraindikasjoner</b>
		<table>
			<xsl:for-each select="//lso:InfItem">
			<tr>
			<td>
				<xsl:if test="lso:Observation"><xsl:value-of select="lso:Observation/lso:Description"/><br/><xsl:value-of select="lso:Observation/lso:CodedDescr/@V"/>&#160;<xsl:value-of select="lso:Observation/lso:CodedDescr/@DN"/></xsl:if>
				<xsl:if test="lso:Type"></xsl:if>
				</td>
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
