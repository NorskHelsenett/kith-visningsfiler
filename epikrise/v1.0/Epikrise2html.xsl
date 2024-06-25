<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:dis="http://www.kith.no/xmlstds/epikrise" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	exclude-result-prefixes="dis xhtml">

<xsl:output method="html" version="4.01" encoding="UTF-8" indent="yes" 
	omit-xml-declaration="yes" 
	doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"   
	doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<!--
FORMÅL
XSLT for generering av html fra Epikrise v.1.0

ENDRINGER:
25.10.2016: La til variabel for visningsversjonnr
07.01.2008: Første versjon

TODO/Svakheter:
* CodedComment og andre kode verdier som ikke er fastsatt i IG men baserer seg på eksterne kodeverk vil ikke vises med mindre teksten er med i DN-feltet

-->

	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'epikrise1.0 v3.1.0 '"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>Epikrise</title>
				<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
				<style type="text/css">
					
.Header
{
width: 95%;
margin: 1px;
border:1px solid gray;
padding:1em;
background-color: #eeeeee;
font-family: arial;
font-size: 0.8em;
}
.ServProvider,.Patient, .Requester, .CopyDest 
{
width: 45%;
height: 10em;
float: left;
border: solid black 1px;
padding: 0.5em;
margin: 0.5em;
}

.Document
{
width:95%;
clear:left;
margin: 1px;
border:1px solid gray;
padding:1em;
background-color: #eeeeee;
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

.Document table
{
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
	
	<!-- Meldingshodet - avsender og mottaker-informasjon -->
	<xsl:template name="Header">
	<div class="Header"> 
					<div class="ServProvider">
					<b>Avsender</b>
					<br/>
					<xsl:apply-templates select="dis:ServProvider"/>
				</div>
					<div class="Patient">
						<b>Pasient</b>
						<br/>
						<xsl:apply-templates select="dis:Patient"/>
					</div>
			<div class="Requester">
						<b>Mottaker</b>
						<br/>
						<xsl:apply-templates select="dis:Requester"/>
			</div>		
				<div class="CopyDest">
					<b>Kopimottaker(e)</b>
					<br/>
					<xsl:apply-templates select="dis:CopyDest"/>
				</div>
		</div> <!-- CSS klasse for meldingshodet-->
	</xsl:template>

	<xsl:template match="dis:Requester">
		<!-- utelatt rolle -->
		<xsl:apply-templates select="dis:HCP"/>
	 </xsl:template>

	<xsl:template match="dis:ServProvider">
	<!-- utelater rolle, da denne kun er "Tjenesteyter" -->
		<xsl:apply-templates select="dis:HCP"/>
	</xsl:template>

	<xsl:template match="dis:Patient">
		<xsl:value-of select="dis:Name"/><br/>
		<xsl:value-of select="dis:TypeOffId/@V"/>:&#160;<xsl:value-of select="dis:OffId"/><br/>
		<xsl:if test="dis:DateOfBirth">Fødselsdato:&#160;<xsl:apply-templates select="dis:DateOfBirth"/><br/></xsl:if>
		<xsl:apply-templates select="dis:Address"/>
	</xsl:template>
	
	<xsl:template match="dis:HCP">
		<!-- utelater MedSpeciality -->
		<xsl:apply-templates select="dis:Inst"/>
		<xsl:apply-templates select="dis:HCProf"/>
		<xsl:apply-templates select="dis:Address"/>
	</xsl:template>
	
	<xsl:template match="dis:Inst">
		<xsl:apply-templates select="dis:HCPerson"/>
		<xsl:value-of select="dis:Name"/><br/> <!-- utelater id -->
		<xsl:for-each select="dis:Dept"><xsl:value-of select="dis:Name"/><br/></xsl:for-each>
	</xsl:template>
	
	<xsl:template match="dis:HCPerson">
		<xsl:value-of select="dis:Name"/>
		<xsl:if test="dis:Id">&#160;-&#160;<xsl:value-of select="dis:TypeId/@V"/>:<xsl:value-of select="dis:Id"/></xsl:if><br/>
	</xsl:template>
	
	<xsl:template match="dis:HCProf">
		<xsl:if test="dis:Type"><xsl:value-of select="dis:Type/@DN"/>&#160;</xsl:if>
		<xsl:value-of select="dis:Name"/>
		<xsl:if test="dis:Id">&#160;-&#160;<xsl:value-of select="dis:TypeId/@V"/>:<xsl:value-of select="dis:Id"/></xsl:if><br/>
	</xsl:template>

	<xsl:template match="dis:CopyDest">
		<!-- utelatt rolle og copydestrole -->
		<xsl:apply-templates select="dis:HCP"/>
	</xsl:template>

	<xsl:template match="dis:Address">
	<xsl:if test="dis:TypeAddress"><b><xsl:value-of select="dis:TypeAddress/@DN"/></b><br/></xsl:if>
	<xsl:if test="dis:StreetAdr"><xsl:value-of select="dis:StreetAdr"/><br/></xsl:if>
	<xsl:if test="dis:PostalCode"><xsl:value-of select="dis:PostalCode"/>&#xA0;</xsl:if>
	<xsl:if test="dis:City"><xsl:value-of select="dis:City"/><br/></xsl:if>
	<xsl:if test="dis:County"><xsl:value-of select="dis:County/@DN"/><br/></xsl:if>
	<xsl:if test="dis:Country"><xsl:value-of select="dis:Country/@DN"/><br/></xsl:if><br/>
	</xsl:template>

	<xsl:template match="dis:TeleAdress">
		<xsl:value-of select="dis:TeleAddress/@V"/>
		<br/>
	</xsl:template>

	<xsl:template match="dis:Event">
		<h2><xsl:choose>
			<xsl:when test="dis:PlannedEvent">Planlagt&#160;</xsl:when>
			<xsl:otherwise>Rapportert&#160;</xsl:otherwise>
		</xsl:choose>hendelse</h2>
		
		<table width="95%">
			<tbody>
				<tr>
					<th colspan="6">Informasjon om hendelsen - <xsl:apply-templates select="dis:ServType"/></th>
				</tr>
				<tr>
					<xsl:if test="dis:Service/dis:Id">
					<th>Identifikasjon/Spesifikasjon</th><td><xsl:value-of select="dis:Service/dis:ServId/@DN"/></td>
					</xsl:if>
					<xsl:if test="dis:Service/dis:MedSpeciality">
						<th>Medisinsk spesialitet</th><td><xsl:value-of select="dis:Service/dis:MedSpeciality/@DN"/></td>
					</xsl:if>
					<xsl:if test="dis:Service/dis:AdmCat">
						<th>Pasientadministrativ type tjeneste</th><td><xsl:apply-templates select="dis:Service/dis:AdmCat"/></td>
					</xsl:if>
					<th>Mottaker av tjenesten</th><td><xsl:apply-templates select="dis:Recipient"/></td>
				</tr>
				<xsl:for-each select="dis:ReportedEvent">
					<tr>
						<th>Startdato</th><td><xsl:value-of select="dis:StartDateTime/@V"/></td>
						<th>Sluttdato</th><td><xsl:value-of select="dis:EndDateTime/@V"/></td>
					</tr>
				</xsl:for-each>
				<tr>					
					<th>Utskrivningsmåte</th><td><xsl:apply-templates select="dis:AdmOutcome"/></td>
					<th>Hastegrad</th><td><xsl:apply-templates select="dis:Priority"/></td>	
					<th>Forventet varighet</th><td><xsl:value-of select="dis:ExpDuration/@V"/>&#160;<xsl:value-of select="dis:ExpDuration/@U"/></td>
				</tr>
				<xsl:for-each select="dis:PlannedEvent">
					<tr>
						<th>Planleggingstrinn</th><td><xsl:apply-templates select="dis:PlanningStage"/></td>
						<th>Status for planen</th><td><xsl:choose><xsl:when test="dis:StatusOfPlan/@V='1'">Foreslått</xsl:when><xsl:otherwise>Bestilt</xsl:otherwise></xsl:choose></td>
					</tr>
					<xsl:if test="dis:PlanComment">
						<tr>
							<th>Kommentar til status</th><td><xsl:value-of select="dis:PlanComment"/></td>
						</tr>
					</xsl:if>
					<tr>
						<th>Planleggingstidspunkt</th><td><xsl:value-of select="dis:PlanningDate/@V"/></td>
						<th>Planlagt tidspunkt</th><td><xsl:value-of select="dis:ScheduledDate/@V"/></td>
						<th>Råd gitt til</th><td><xsl:apply-templates select="dis:AdviceSentTo"/></td>
					</tr>
					<tr>
						<th>Forventet ventetid</th><td><xsl:value-of select="dis:ExpectedDelay/@V"/>&#160;<xsl:value-of select="dis:ExpectedDelay/@U"/></td>
						<th>Kommentar til ventetid</th><td><xsl:value-of select="dis:CommentExpDuration"/></td>
					</tr>
					<xsl:if test="dis:Preparation">
						<tr>
							<th>Instruksjon</th><td><xsl:value-of select="dis:Preparation"/></td>
						</tr>
					</xsl:if>
					<xsl:if test="dis:Advice">
						<tr>
							<th>Råd til pasient</th><td><xsl:value-of select="dis:Advice"/></td>
						</tr>
					</xsl:if>
					<xsl:for-each select="dis:TransportArr">
						<tr>
							<th colspan="6">Pasienttransportforberedelse</th>
						</tr>
						<tr>
							<th>Ansvarlig</th><td><xsl:apply-templates select="dis:Responsibility"/></td>
							<th>Status</th><td><xsl:apply-templates select="dis:Status"/></td>
						</tr>
						<tr>
							<th>Behov for ledsagelse</th><td><xsl:apply-templates select="dis:EscortRequired"/></td>
						</tr>
						<tr>
							<th>Kommentar</th><td><xsl:value-of select="dis:Comment"/></td>
						</tr>
					</xsl:for-each>
				</xsl:for-each><!-- Planned event -->
				<xsl:for-each select="dis:EventLocation">
					<tr>
						<th colspan="6"><xsl:choose>
							<xsl:when test="dis:Role"><xsl:apply-templates select="dis:Role"/></xsl:when><xsl:otherwise>Sted</xsl:otherwise>
						</xsl:choose></th>						
					</tr>
					<tr>
						<th>Sted</th><td><xsl:apply-templates select="dis:Location/dis:Inst"/><br/><xsl:apply-templates select="dis:Location/dis:Address"/></td>
						<xsl:if test="dis:Location/dis:SubLocation"><th><xsl:apply-templates select="dis:Type"/></th><td><xsl:value-of select="dis:Location/dis:SubLocation/dis:Place"/></td></xsl:if>
					</tr>
					<tr>
						<th>Starttidspunkt</th><td><xsl:value-of select="dis:StartDateTime/@V"/></td>
						<th>Sluttidspunkt</th><td><xsl:value-of select="dis:EndDateTime/@V"/></td>
					</tr>
				</xsl:for-each><!-- eventlocation -->
			</tbody>
		</table>

		<xsl:apply-templates select="dis:InfItem"/>
<!-- Struktur for å samle medisin-informasjon -->		
				<xsl:if test="dis:InfItem/dis:Medication">
				<h3>Legemidler</h3>
				<table width="95%">
					<tbody>
					<xsl:for-each select="dis:InfItem/dis:Medication">
					
				<tr>
					<th colspan="8">Medikament</th>
				</tr>			
				<tr>
				<td>&#160;</td>
				<td>
				<table width="100%">
					<tbody>
			
				<tr>
					<th>Legemiddel</th>
					<th>Styrke</th>
					<th>Dosering</th>
					<th>Status</th>
					<th>Planlagt varighet</th>
				</tr>
				<tr>
					<td><xsl:value-of select="dis:DrugId/@DN"/> <xsl:value-of select="dis:DrugId/@OT"/></td>
					<td><xsl:value-of select="dis:UnitDose/@V"/> <xsl:value-of select="dis:UnitDose/@U"/></td>
					<td ><xsl:value-of select="dis:DosageText"/> <xsl:if test="dis:DosageCoded">(Kodet: <xsl:value-of select="dis:DosageCoded/@DN"/>)</xsl:if></td>
					<td><xsl:apply-templates select="dis:Status"/></td>
					<td ><xsl:value-of select="dis:IntendedDuration/@V"/> <xsl:value-of select="dis:IntendedDuration/@U"/></td>
				</tr>
				<xsl:if test="dis:RouteOfAdm or dis:Form or dis:QuantitySupplied">
					<tr>
						<th>Mengde utlevert</th><td><xsl:value-of select="dis:QuantitySupplied/@V"/> <xsl:value-of select="dis:QuantitySupplied/@DN"/></td>
						<th>Tilberedningsform</th><td><xsl:value-of select="dis:Form/@DN"/></td>
						<th>Administrasjonsform</th><td><xsl:value-of select="dis:RouteOfAdm/@DN"/></td>
					</tr>
				</xsl:if>
				<xsl:if test="../dis:StartDateTime or ../dis:EndDateTime or ../dis:OrgDate">
				<tr>
					<th>Starttidspunkt</th><td><xsl:value-of select="../dis:StartDateTime/@V"/></td>
					<th>Sluttidspunkt</th><td><xsl:value-of select="../dis:EndDateTime/@V"/></td>
					<th>Tidspunkt for opprinnelse</th><td><xsl:value-of select="../dis:OrgDate/@V"/></td>
				</tr>
				</xsl:if>

				<xsl:if test="dis:Comment">
				<tr>
					<th>Kommentar</th><td colspan="6"><xsl:apply-templates select="dis:Comment"/></td>
				</tr>
				</xsl:if>
				
				<xsl:if test="../dis:Origin">
				<tr>
					<th>Opphav til opplysningen</th><td colspan="5"><xsl:apply-templates select="../dis:Origin/dis:HCP"/></td>
				</tr>
				</xsl:if>
				<xsl:for-each select="../dis:RelHCProvider">
				<tr>
					<th colspan="2">Tilknyttet klinisk tjenesteyter - <xsl:apply-templates select="/dis:Relation"/></th>
					<td colspan="4"><xsl:apply-templates select="dis:HCP"/></td>
				</tr>				
				</xsl:for-each>
				</tbody></table></td>
				</tr>
				</xsl:for-each>
				
					</tbody>
				</table>
			</xsl:if>
<!-- slutt struktur for å samle medisineringsinformsajon-->
		
		<xsl:apply-templates select="dis:Comment"/>
		<xsl:if test="dis:CodedComment">
		<h3>Kodede kommentarer til hendelsen</h3>
			<xsl:for-each select="dis:CodedComment"><!-- Støttes kun hvis DN er oppgitt -->
				Kode:&#160;<xsl:value-of select="dis:Concept/@DN"></xsl:value-of><br/>
				Modifikatorer:<br/>
				<xsl:for-each select="dis:Modifier">
					<xsl:choose>
						<xsl:when test="dis:Name/@V='S'">ICD10 stjernekode:&#160;</xsl:when>
						<xsl:otherwise>ICD10 ATC-kode:&#160;</xsl:otherwise>
					</xsl:choose><xsl:value-of select="dis:Value/@DN"/>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:if>

	</xsl:template>
	
	<xsl:template match="dis:InfItem">
		<xsl:if test="not(dis:Medication)"><!-- Medication håndteres samlet i Event -->
		<h3><xsl:apply-templates select="dis:Type"/></h3>
		<table width="95%">
			<tbody>
				<xsl:if test="dis:StartDateTime or dis:EndDateTime or dis:OrgDate">
				<tr>
					<th>Starttidspunkt</th><td><xsl:value-of select="dis:StartDateTime/@V"/></td>
					<th>Sluttidspunkt</th><td><xsl:value-of select="dis:EndDateTime/@V"/></td>
					<th>Tidspunkt for opprinnelse</th><td><xsl:value-of select="dis:OrgDate/@V"/></td>
				</tr>
				</xsl:if>
				<tr>
					<td colspan="6"><xsl:apply-templates select="dis:Observation"/><xsl:apply-templates select="dis:ResultItem"/></td><!-- nested table med infitem'et -->
				</tr>
				<xsl:if test="dis:Origin">
				<tr>
					<th>Opphav til opplysningen</th><td colspan="5"><xsl:apply-templates select="dis:Origin/dis:HCP"/></td>
				</tr>
				</xsl:if>
				<xsl:for-each select="dis:RelHCProvider">
				<tr>
					<th colspan="2">Tilknyttet klinisk tjenesteyter - <xsl:apply-templates select="dis:Relation"/></th>
					<td colspan="4"><xsl:apply-templates select="dis:HCP"/></td>
				</tr>				
				</xsl:for-each>
			</tbody>
		</table>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="dis:Observation">
		<table width="100%">
			<tbody>
			<xsl:if test="dis:Description">
				<tr>
					<th>Beskrivelse</th>
				</tr>
				<tr>
					<td><xsl:value-of select="dis:Description"/></td>
				</tr>
				</xsl:if>
				<xsl:if test="dis:Comment">
				<tr>
					<th>Kommentar</th>
				</tr>
				<tr>
					<td><xsl:value-of select="dis:Comment"/></td>
				</tr>
				</xsl:if>
				<xsl:if test="dis:CodedDescr">
				<tr>
					<th>Kodet beskrivelse</th>
				</tr>
				<tr>
					<td><xsl:apply-templates select="dis:CodedDescr"/></td>
				</tr>
				</xsl:if>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="dis:Observation/dis:CodedDescr">
		<xsl:value-of select="dis:Concept/@V"/>&#160;-&#160;<xsl:value-of select="dis:Concept/@DN"></xsl:value-of>
				<xsl:for-each select="dis:Modifier">,&#160;
					<xsl:choose>
						<xsl:when test="dis:Name/@V='S'">ICD10 stjernekode:&#160;</xsl:when>
						<xsl:otherwise>ICD10 ATC-kode:&#160;</xsl:otherwise>
					</xsl:choose><xsl:value-of select="dis:Value/@DN"/>
					</xsl:for-each>
	</xsl:template>

	
	<xsl:template match="dis:ResultItem">
		<table>
			<tbody>
				<tr>
					<th>Undersøkelsesresultat - <xsl:apply-templates select="dis:ServType"/><xsl:if test="dis:InvDate"> - <xsl:value-of select="dis:InvDate/@V"/></xsl:if></th>
				</tr>
				<tr>
					<th>Undersøkelse</th><td><xsl:value-of select="dis:ClinInv/dis:Id/@DN"/><xsl:value-of select="dis:ClinInv/dis:Id/@OT"/></td>
				</tr>
				<tr>
					<th>Resultat</th><td><xsl:apply-templates/></td>
				</tr>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="dis:TextResult/dis:Result">
		<b><xsl:apply-templates select="dis:Heading"/></b><br/>
		<xsl:value-of select="dis:TextResultValue"/><br/>
		<xsl:value-of select="dis:TextCode/@DN"/>
	</xsl:template>
	
	<xsl:template match="dis:Interval">
		Intervall: <xsl:value-of select="dis:Low/@V"/> <xsl:value-of select="dis:Low/@U"/> - <xsl:value-of select="dis:High/@V"/> <xsl:value-of select="dis:Low/@U"/>
	</xsl:template>
	
	<xsl:template match="dis:NumResult">
		<xsl:apply-templates select="dis:ArithmeticComp"/>&#160;<xsl:value-of select="dis:NumResultValue/@V"/>&#160;<xsl:value-of select="dis:NumResultValue/@U"/>
	</xsl:template>
	
	<xsl:template match="dis:DateResult">
		<xsl:value-of select="dis:DateResultValue/@V"/>
	</xsl:template>
	
	<xsl:template match="dis:Comment">
		<h3><xsl:apply-templates select="dis:Heading"/></h3>
		<p><xsl:call-template name="line-breaks"><xsl:with-param name="text" select="dis:TextResultValue"></xsl:with-param></xsl:call-template></p>
	</xsl:template>
		
	<xsl:template match="dis:Message"><!-- utelater meldingsid og kommunikasjonsinformasjon -->
		<xsl:apply-templates select="dis:ServRprt"/>
	</xsl:template>	
	
	<xsl:template match="dis:ServRprt">
		<xsl:call-template name="Header"/>
		<div class="Document">
		<h1>Epikrise</h1>
		<table width="95%">
			<thead>
				<tr>
					<th colspan="8">Meldingsinformasjon</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<th>Status</th><td><xsl:apply-templates select="dis:ServType"/> - <xsl:apply-templates select="dis:Status"/></td>
					<th>Utstedt</th><td><xsl:value-of select="dis:IssueDate/@V"/></td>
					<th>Godkjent</th><td><xsl:value-of select="dis:ApprDate/@V"/></td>
					<th>Hastegrad</th><td><xsl:apply-templates select="dis:Priority"/></td>
				</tr>
				<tr>
					<th>Type epikrise</th><td colspan="7"><xsl:value-of select="dis:MsgDescr"/></td>
				</tr>
			</tbody>
		</table>
		
		<xsl:if test="dis:Patient/dis:DateOfDeath | dis:Patient/dis:MaritalStatus | dis:Patient/dis:AdditionalId | dis:Patient/dis:PatientPrecaution |dis:Patient/dis:Sex" >
		<h2>Øvrig pasientinformasjon</h2>
		<xsl:for-each select="dis:Patient">
		<table width="95%">
			<tbody>
				<tr>
					<th colspan="10">Pasientinformasjon</th>
				</tr>
				<tr>
					<th>Navn</th><td><xsl:value-of select="dis:Name"/></td>
					<th>Kjønn</th><td><xsl:apply-templates select="dis:Sex"/></td>
					<th>Fødselsdato</th><td><xsl:value-of select="dis:DateOfBirth/@V"/></td>
					<th>Dødsdato</th><td><xsl:value-of select="dis:DateOfDeath/@V"/></td>
					<th>Sivilstatus</th><td><xsl:apply-templates select="dis:MaritalStatus"/></td>
				</tr>
				<xsl:if test="dis:AdditionalId">
				<tr>
					<th>Andre identifikatorer</th>
				</tr>
					<xsl:for-each select="dis:AdditionalID">
						<tr>
							<th><xsl:value-of select="dis:Type/@V"/></th>
							<td><xsl:value-of select="dis:Id"/></td>
						</tr>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="dis:PatientPrecaution">
					<tr>
						<th colspan="8">Advarsel til tjenesteyter</th>
					</tr>
					<xsl:for-each select="dis:PatientPrecaution">
						<tr>
							<th>Advarsel</th>
							<td colspan="3"><xsl:value-of select="dis:Precaution"/></td>
							<th>Gyldig fra</th><td><xsl:value-of select="dis:StartDateTime/@V"/>&#160;</td>
							<th>Gyldig til</th><td><xsl:value-of select="dis:EndDateTime/@V"/>&#160;</td>
						</tr>
					</xsl:for-each>
				</xsl:if>
			</tbody>
		</table>
		<br/>
		
		</xsl:for-each>
		</xsl:if>
		
		<xsl:apply-templates select="dis:Event"/>


		<xsl:if test="dis:Patient/dis:PatRelHCP">
	<h2>Pasientrelaterte helsetjenesteenheter</h2>
			<table>
				<tbody>
					<tr>
						<th colspan="8">Pasientrelatert helsetjenesteenhet</th>
					</tr>		
			<xsl:for-each select="dis:Patient/dis:PatRelHCP">
					<tr>
						<th>Relasjon</th>
						<td>Fastlege</td><!-- Hardkodet - kun fastlege i DIM-->
						<th>Person/enhet</th><td><xsl:apply-templates select="dis:HCP"/></td>
						<th>Fradato</th><td><xsl:value-of select="dis:StartDateTime/@V"/></td>
						<th>Tildato</th><td><xsl:value-of select="dis:EndDateTime/@V"/></td>
					</tr>
		</xsl:for-each>
			</tbody>
		</table>
		<br/>
		</xsl:if>
		<xsl:if test="dis:PatientRelParty">
			<h2>Pasientrelaterte parter</h2>
		<table>
			<tbody>
				<tr>
					<th colspan="6">Pasientrelatert part</th>
				</tr>
				<xsl:for-each select="dis:PatientRelParty">
				<tr>
					<th>Relasjon</th>
					<td><xsl:apply-templates select="dis:Relation"/></td>
					<th>Navn</th>
					<td><xsl:value-of select="dis:Name"/></td>
					<th>Offentlig id</th>
					<td><xsl:value-of select="dis:RelPartyOffId"/></td>
				</tr>
				</xsl:for-each>
			</tbody>
		</table>
		<br/>
		</xsl:if>

		</div>
	</xsl:template>
	
	
<!-- Hack for å få til linjeskift - for bruk ved datatypen ST eller string -->
<!--	<xsl:call-template name="line-breaks"><xsl:with-param name="text" select="dia:TekstNotatInnhold"></xsl:with-param>  </xsl:call-template> -->
<xsl:template name="line-breaks">
  <xsl:param name="text"/>
  <xsl:choose>
    <xsl:when test="contains($text,'&#10;')">
      <xsl:value-of select="substring-before($text,'&#10;')"/>
      <br/>
      <xsl:call-template name="line-breaks">
        <xsl:with-param name="text"  select="substring-after($text,'&#10;')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$text"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
	
  <!-- Funksjoner for kodeverk -->
  <xsl:template match="dis:ServType">
      <xsl:choose>
		<xsl:when test="@V='N'">Ny</xsl:when>
		<xsl:when test="@V='M'">Endring</xsl:when>
		<xsl:when test="@V='C'">Kansellering</xsl:when>
		<xsl:when test="@V='A'">Tillegg</xsl:when>
	</xsl:choose>
  </xsl:template>	
  <xsl:template match="dis:ServRprt/dis:Status">
      <xsl:choose>
		<xsl:when test="@V='A'">Tillegg til rapport</xsl:when>
		<xsl:when test="@V='F'">Endelig rapport</xsl:when>
		<xsl:when test="@V='P'">Foreløpig rapport</xsl:when>
	</xsl:choose>
  </xsl:template>	
  <xsl:template match="dis:ServRprt/dis:Priority">
      <xsl:choose>
		<xsl:when test="@V='DATO'">Innen dato/klokkeslett</xsl:when>
		<xsl:when test="@V='NORM'">Normal</xsl:when>
		<xsl:when test="@V='OHJELP'">Øyeblikkelig hjelp</xsl:when>
		<xsl:when test="@V='TEL'">Besvares pr. telefon</xsl:when>
	</xsl:choose>
  </xsl:template>	
  <xsl:template match="dis:Patient/dis:Sex">
	  <xsl:choose>
				<xsl:when test="@V='1'">Mann</xsl:when>
				<xsl:when test="@V='2'">Kvinne</xsl:when>
				<xsl:when test="@V='9'">Ikke spesifisert</xsl:when>
			</xsl:choose>
  </xsl:template>
  <xsl:template match="dis:PatientRelParty/dis:Relation">
	  <xsl:choose>
  				<xsl:when test="@V='FAR'">Far</xsl:when>
				<xsl:when test="@V='MOR'">Mor</xsl:when>
				<xsl:when test="@V='SØN'">Sønn</xsl:when>
				<xsl:when test="@V='DTR'">Datter</xsl:when>
				<xsl:when test="@V='BBN'">Barnebarn</xsl:when>
				<xsl:when test="@V='ASL'">Annen slektning</xsl:when>
				<xsl:when test="@V='VEN'">Venn</xsl:when>
				<xsl:when test="@V='KOL'">Arbeidskollega</xsl:when>
				<xsl:when test="@V='NBO'">Nabo</xsl:when>
				<xsl:when test="@V='ARE'">Annen relasjon</xsl:when>
		</xsl:choose>
  </xsl:template>
  <xsl:template match="dis:Event/dis:Recipient">
	  <xsl:choose>
				<xsl:when test="@V='1'">Pasienten selv</xsl:when>
				<xsl:when test="@V='2'">Pasienten og pårørende</xsl:when>
				<xsl:when test="@V='9'">Pasient og barn</xsl:when>
			</xsl:choose>
  </xsl:template>
  <xsl:template match="dis:Service/dis:AdmCat">
	  <xsl:choose>
				<xsl:when test="@V='1'">Heldøgnsopphold (7 dager i uken)</xsl:when>
				<xsl:when test="@V='2'">Dagbehandling</xsl:when>
				<xsl:when test="@V='3'">Poliklinisk omsorg</xsl:when>
				<xsl:when test="@V='4'">Telekonsultasjon</xsl:when>
				<xsl:when test="@V='5'">Konsultasjon</xsl:when>
				<xsl:when test="@V='6'">Telefonkonsultasjon</xsl:when>
			</xsl:choose>
  </xsl:template>
  <xsl:template match="dis:Event/dis:Priority">
	  <xsl:choose>
				<xsl:when test="@V='0'">Umiddelbart</xsl:when>
				<xsl:when test="@V='1'">Innen 24 timer</xsl:when>
				<xsl:when test="@V='180'">Innen 6 måneder</xsl:when>
				<xsl:when test="@V='2'">Innen 2 døgn</xsl:when>
				<xsl:when test="@V='30'">Innen en måned</xsl:when>
				<xsl:when test="@V='7'">Innen en uke</xsl:when>
				<xsl:when test="@V='90'">Innen 3 måneder</xsl:when>
			</xsl:choose>
  </xsl:template>
  <xsl:template match="dis:Event/dis:AdmOutcome">
	  <xsl:choose>
				<xsl:when test="@V='1'">Vanlig bosted, arbeidssted mv.</xsl:when>
				<xsl:when test="@V='2'">Som død</xsl:when>
				<xsl:when test="@V='3'">Annen institusjon (inklusiv psykiatrisk avd. ved egen inst.)</xsl:when>
				<xsl:when test="@V='4'">Sykehus i utlandet</xsl:when>
				<xsl:when test="@V='6'">Annet</xsl:when>
				<xsl:when test="@V='9'">Annen somatisk avdeling ved egen institusjon</xsl:when>
			</xsl:choose>
  </xsl:template>
  <xsl:template match="dis:PlannedEvent/dis:PlanningStage">
	  <xsl:choose>
				<xsl:when test="@V='1'">Foreslått</xsl:when>
				<xsl:when test="@V='2'">Bestillt</xsl:when>
				<xsl:when test="@V='3'">Avtalt</xsl:when>
				<xsl:when test="@V='4'">Utsatt</xsl:when>
				<xsl:when test="@V='6'">Kansellert</xsl:when>
			</xsl:choose>
  </xsl:template>
  <xsl:template match="dis:PlannedEvent/dis:AdviceSentTo">
			  <xsl:choose>
				<xsl:when test="@V='1'">Til pasienten direkte</xsl:when>
				<xsl:when test="@V='2'">Til pasientens lege</xsl:when>
				<xsl:when test="@V='3'">Til pårørende</xsl:when>
			</xsl:choose>
  </xsl:template>
<xsl:template match="dis:TransportArr/dis:Responsibility">
	  <xsl:choose>
				<xsl:when test="@V='1'">Henvisende instans</xsl:when>
				<xsl:when test="@V='2'">Tjenesteyter</xsl:when>
				<xsl:when test="@V='3'">Pasienten selv</xsl:when>
				<xsl:when test="@V='4'">Pårørende</xsl:when>
				<xsl:when test="@V='9'">Uspesifisert</xsl:when>
			</xsl:choose>
  </xsl:template>
<xsl:template match="dis:TransportArr/dis:Status">
	  <xsl:choose>
				<xsl:when test="@V='1'">Foreslått</xsl:when>
				<xsl:when test="@V='2'">Bestilt</xsl:when>
				<xsl:when test="@V='3'">Tildelt</xsl:when>
				<xsl:when test="@V='9'">Ikke kjent</xsl:when>
			</xsl:choose>
  </xsl:template>
<xsl:template match="dis:TransportArr/dis:EscortRequired">
	  <xsl:choose>
				<xsl:when test="@V='1'">Trenger ledsager</xsl:when>
				<xsl:when test="@V='2'">Blir ledsaget</xsl:when>
				<xsl:when test="@V='3'">Klarer seg alene</xsl:when>
			</xsl:choose>
  </xsl:template>
  <xsl:template match="dis:EventLocation/dis:Role">
	  <xsl:choose>
				<xsl:when test="@V='1'">Oppholdssted</xsl:when>
				<xsl:when test="@V='2'">Innlagt fra</xsl:when>
				<xsl:when test="@V='3'">Utskrevet til</xsl:when>
				<xsl:when test="@V='4'">Sted for hendelse</xsl:when>
				<xsl:when test="@V='5'">Skadested</xsl:when>
			</xsl:choose>
  </xsl:template>
    <xsl:template match="dis:SubLocation/dis:Type">
	  <xsl:choose>
				<xsl:when test="@V='1'">Seksjon</xsl:when>
				<xsl:when test="@V='2'">Sengepost</xsl:when>
				<xsl:when test="@V='3'">Rom</xsl:when>
				<xsl:when test="@V='4'">Seng</xsl:when>
				<xsl:when test="@V='5'">Operasjonsstue</xsl:when>
			</xsl:choose>
  </xsl:template>
  <xsl:template match="dis:Comment/dis:Heading">
	  <xsl:choose>
  				<xsl:when test="@V='TB'">Tilbakemelding (uspes.)</xsl:when>
				<xsl:when test="@V='TS'">Tidligere sykdom</xsl:when>
				<xsl:when test="@V='ME'">Medisinering</xsl:when>
				<xsl:when test="@V='LR'">Laboratorieresultat</xsl:when>
				<xsl:when test="@V='ÅI'">Årsak til innleggelse</xsl:when>
				<xsl:when test="@V='FA'">Familie/sosialt</xsl:when>
				<xsl:when test="@V='FU'">Funn og undersøkelsesresultater</xsl:when>
				<xsl:when test="@V='FO'">Forløp og behandling</xsl:when>
				<xsl:when test="@V='UP'">Ubesvarte prøver</xsl:when>
				<xsl:when test="@V='HJ'">Funksjonsnivå/hjelpetiltak</xsl:when>
				<xsl:when test="@V='VU'">Vurdering</xsl:when>
				<xsl:when test="@V='OP'">Planer for videre oppfølging</xsl:when>
				<xsl:when test="@V='SY'">Sykmelding</xsl:when>
				<xsl:when test="@V='IP'">Informasjon til pasient/pårørende</xsl:when>
		</xsl:choose>
  </xsl:template>
    <xsl:template match="dis:InfItem/dis:Type">
	  <xsl:choose>
				<xsl:when test="@V='ANAM'">Sykehistorie</xsl:when>
				<xsl:when test="@V='SYMP'">Symptom</xsl:when>
				<xsl:when test="@V='PROG'">Prognose</xsl:when>
				<xsl:when test="@V='OPIN'">Inngrep/operasjon</xsl:when>
				<xsl:when test="@V='H'">Hoveddiagnose</xsl:when>
				<xsl:when test="@V='B'">Bidiagnose</xsl:when>
				<xsl:when test="@V='MEDB'">Medikamentell behandling</xsl:when>
				<xsl:when test="@V='FUNN'">Funn/undersøkelsesresultat</xsl:when>
				<xsl:when test="@V='OPPL'">Klinisk opplysning (uspes.)</xsl:when>
				<xsl:when test="@V='TIDBL'">Tidligere behandling</xsl:when>
				<xsl:when test="@V='CAVE'">Cave-opplysninger</xsl:when>
			</xsl:choose>
  </xsl:template>
    <xsl:template match="dis:RelHCProvider/dis:Relation">
	  <xsl:choose>
				<xsl:when test="@V='ANL'">Anestesist</xsl:when>
				<xsl:when test="@V='AUT'">Dokumentgodkjenner</xsl:when>
				<xsl:when test="@V='BLE'">Behandlende lege</xsl:when>
				<xsl:when test="@V='ISS'">Dokumentutsteder</xsl:when>
				<xsl:when test="@V='OPL'">Operatør</xsl:when>
				<xsl:when test="@V='REG'">Person som har registrert opplysningen</xsl:when>
			</xsl:choose>
  </xsl:template>
  <xsl:template match="dis:Medication/dis:Status">
  	  <xsl:choose>
				<xsl:when test="@V='1'">Inntatt</xsl:when>
				<xsl:when test="@V='2'">Forskrevet</xsl:when>
				<xsl:when test="@V='3'">Anbefalt å innta</xsl:when>
				<xsl:when test="@V='4'">Anbefalt å slutte å innta</xsl:when>
				<xsl:when test="@V='5'">Benyttes sporadisk</xsl:when>
				<xsl:when test="@V='6'">Benyttes regelmessig</xsl:when>
				<xsl:when test="@V='10'">Allergisk ovenfor</xsl:when>
			</xsl:choose>
  </xsl:template>
    <xsl:template match="dis:Result/dis:Heading">
	  <xsl:choose>
				<xsl:when test="@V='ME'">Medisinering</xsl:when>
				<xsl:when test="@V='LR'">Laboratorieresultat</xsl:when>
				<xsl:when test="@V='FU'">Funn og undersøkelsesresultater</xsl:when>
				<xsl:when test="@V='VU'">Vurdering</xsl:when>
				<xsl:when test="@V='OP'">Planer for videre oppfølging</xsl:when>
				<xsl:when test="@V='IP'">Informasjon til pasient/pårørende</xsl:when>
			</xsl:choose>
  </xsl:template>
    <xsl:template match="dis:NumResult/dis:ArithmeticComp">
	  <xsl:choose>
				<xsl:when test="@V='EQ'">Lik</xsl:when>
				<xsl:when test="@V='GE'">Større eller lik</xsl:when>
				<xsl:when test="@V='GT'">Større</xsl:when>
				<xsl:when test="@V='LE'">Mindre eller lik</xsl:when>
				<xsl:when test="@V='LT'">Mindre</xsl:when>
				<xsl:when test="@V='NE'">Forskjellig</xsl:when>
				<xsl:when test="@V='MG'">Mye større</xsl:when>
				<xsl:when test="@V='ML'">Mye mindre</xsl:when>
			</xsl:choose>
  </xsl:template>
      <xsl:template match="dis:Patient/dis:MaritalStatus">
	  <xsl:choose>
				<xsl:when test="@V='1'">Ugift</xsl:when>
				<xsl:when test="@V='2'">Gift</xsl:when>
				<xsl:when test="@V='3'">Enke(mann)</xsl:when>
				<xsl:when test="@V='4'">Separert</xsl:when>
				<xsl:when test="@V='5'">Skilt</xsl:when>
				<xsl:when test="@V='6'">Registrert partnerskap</xsl:when>
				<xsl:when test="@V='7'">Ukjent</xsl:when>
			</xsl:choose>
  </xsl:template>



</xsl:stylesheet>