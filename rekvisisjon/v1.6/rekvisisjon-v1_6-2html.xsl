<?xml version="1.0" encoding="utf-8"?>
<!-- Endringslogg
	- 19.06.17: v3.1.2: Endret fre "Tjenesteyter" til "Mottaker" og fra "Henvisende instans" til "Avsender" under avsnittet "Helsetjenesteenheter" for å få samsvar med heading. 
	- 27.03.17: v3.1.1: Ny parameter for "visningStil. Ny stil "Smooth".
	- 25.10.16: v3.1.0: La til visningsversjonnr
	- 09.05.14: La til import av kodeverk-fil
	- 27.04.11: La til visning av flere enn en underavdeling ved pasientopphold, la til visning av Comment/TextResultValue, samt erstattet mange <br/> med <div>.
	- 01.12.10: Import av felles CSS-fil
	- 10.07.09: Felles komplett visningsfil for rekvisisjon
	- 04.02.09: Oppdatert adresse for namespace for v1.5
	- 06.05.08: Andre versjon etter forslag sendt inn 28.04
-->
<!-- Design
	- Ingen tomme felt så langt det lar seg gjøre
	- Radene strekkes alltid til full kolonnebredde (bortsett fra enkelte overskrifter) vha formelen:	<td colspan="{(($col)-1-count(<elementer foran>)*2)*number(not(<elementer bak>))+1}">
		- Om det gjenstår elementer bak i raden ( number(not(<elementer bak>))=0 ) gir formelen:	<td colspan="1"> (multipliserer med 0 slik at bare "1" gjenstår)
		- Om det ikke er elementer bak beregner formelen - utfra antall elementer foran i raden - antall kolonner som gjenstår til kolonnebredden ($col) er nådd.
		- Ett-tallene oppveier hverandre
	- Klikkbar menylinje
	- Headervisning avhengig av utskriftsmedium
	- Kommentarer for ofte tildelt fulle rader
-->
<!-- Svakheter
	- Kolonnevariablene er foreløpig ikke dynamiske (forminsker man variablene dannes ikke flere rader)
	- Fravær av obligatoriske element kan gi tomme bokser/rader
	- Fravær av DN-attributt (ev. OT-attributt) kan gi {Ukjent kode} i visningen
-->
<!-- Om
	- Inngår i Hdirs visningsfiler versjon 2.0
	- Laget i XMLSpy v2014 rel.2 sp1 (http://www.altova.com) av Jan Sigurd Dragsjø (nhn.no)
-->
<xsl:stylesheet version="1.0" 
	xmlns="http://www.w3.org/1999/xhtml" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:lso="http://www.kith.no/xmlstds/rekvisisjon/2012-02-15" 
	xmlns:base="http://www.kith.no/xmlstds/base64container" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	exclude-result-prefixes="lso xhtml base">
	
	<xsl:import href="../../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../../felleskomponenter/kodeverk.xsl"/>
	<xsl:import href="../../felleskomponenter/visningstil.xsl"/>


	<!-- Variabler for antall kolonner og bredde -->
	<xsl:variable name="std-col" select="10"/>
	<xsl:variable name="std-td" select="200"/>
	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'rekvisisjon1.6 - v3.1.2 '"/>

	<!-- Meldingsstart -->
	<xsl:template match="/">
		<html>
			<head>
				<title>Rekvisisjon</title>
				<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
				<style type="text/css">
					<xsl:value-of select="document('../../felleskomponenter/KITH-visning.css')" disable-output-escaping="yes"/>
				</style>
				<style type="text/css">
					<xsl:value-of select="document('../../felleskomponenter/smooth-visning.css')" disable-output-escaping="yes"/>
				</style>
			</head>
			<body>
				<xsl:apply-templates/>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="lso:Message">
		<xsl:for-each select="lso:ServReq">
			<!-- utelater meldingsid og kommunikasjonsinformasjon -->
			<xsl:call-template name="Header"/>
			<xsl:call-template name="ResultBody"/>
			<xsl:call-template name="Footer"/>
		</xsl:for-each>
	</xsl:template>
	<!-- Meldingshodet - avsender og mottaker-informasjon -->
	<xsl:template name="Header">
		<div class="No-line-top">
			<div class="No-line-header">
				<div class="No-line-headerContent">
					<div class="No-line-caption">Avsender&#160;</div>
					<div class="No-line-content">
						<xsl:apply-templates select="lso:Requester" mode="hode"/>
					</div>
				</div>
				<xsl:choose>
					<xsl:when test="lso:Patient">
						<div class="No-line-headerContent">
							<div class="No-line-caption">Pasient&#160;</div>
							<div class="No-line-content">
								<xsl:apply-templates select="lso:Patient" mode="hode"/>
							</div>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div class="No-line-headerContent">
							<div class="NoScreen">&#160;</div>
						</div>
					</xsl:otherwise>
				</xsl:choose>
				<div class="No-line-headerContent">
					<div class="No-line-caption">Mottaker&#160;</div>
					<div class="No-line-content">
						<xsl:apply-templates select="lso:ServProvider" mode="hode"/>
					</div>
				</div>
				<xsl:choose>
					<xsl:when test="lso:CopyDest">
						<div class="No-line-headerContent">
							<div class="No-line-caption">Kopimottaker&#160;</div>
							<div class="No-line-content">
								<xsl:apply-templates select="lso:CopyDest" mode="hode"/>
							</div>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div class="No-line-headerContent">
							<div class="NoScreen">&#160;</div>
						</div>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="lso:Requester" mode="hode">
		<xsl:apply-templates select="lso:HCP" mode="hode"/>
	</xsl:template>
	<xsl:template match="lso:ServProvider" mode="hode">
		<xsl:apply-templates select="lso:HCP" mode="hode"/>
	</xsl:template>
	<xsl:template match="lso:Patient" mode="hode">
		<div>
			<xsl:value-of select="lso:Name"/>&#160;
			<span class="strong">
				<xsl:for-each select="lso:TypeOffId">
					<xsl:call-template name="k-8116"/>
				</xsl:for-each>:&#160;</span>
			<xsl:value-of select="lso:OffId"/>&#160;
		</div>
		<xsl:if test="lso:DateOfDeath">
			<div>
				<span class="strong">Dødsdato:&#160;</span>
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="lso:DateOfDeath/@V"/>
				</xsl:call-template>
			</div>
		</xsl:if>
		<xsl:apply-templates select="lso:Address" mode="hode"/>
	</xsl:template>
	<xsl:template match="lso:Animal" mode="hode">
		<div>
			<xsl:if test="lso:Name">
				<span class="strong">Navn</span>:&#160;<xsl:value-of select="lso:Name"/>&#160;</xsl:if>
			<xsl:if test="lso:Species">
				<span class="strong">Art</span>:&#160;<xsl:value-of select="lso:Species"/>&#160;</xsl:if>
			<xsl:if test="lso:NameOwner">
				<span class="strong">Eier</span>:&#160;<xsl:value-of select="lso:NameOwner"/>&#160;</xsl:if>
		</div>
	</xsl:template>
	<xsl:template match="lso:Material" mode="hode">
		<div>
			<xsl:if test="lso:InvMaterial">
				<span class="strong">Beskrivelse</span>:&#160;<xsl:value-of select="lso:InvMaterial"/>&#160;</xsl:if>
		</div>
	</xsl:template>
	<xsl:template match="lso:HCPerson" mode="hode">
		<div>
			<xsl:value-of select="lso:Name"/>
			<div class="NoPrint">,</div>&#160;</div>
	</xsl:template>
	<xsl:template match="lso:HCP" mode="hode">
		<xsl:apply-templates select="lso:Inst" mode="hode"/>
		<xsl:apply-templates select="lso:HCProf" mode="hode"/>
		<xsl:apply-templates select="lso:Address" mode="hode"/>
	</xsl:template>
	<xsl:template match="lso:Inst" mode="hode">
		<xsl:apply-templates select="lso:HCPerson" mode="hode"/>
		<div>
			<xsl:value-of select="lso:Name"/>
		</div>
		<xsl:for-each select="lso:Dept">
			<div>
				<div class="NoPrint">-&#160;</div>
				<xsl:value-of select="lso:Name"/>&#160;</div>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="lso:HCProf" mode="hode">
		<div>
			<xsl:for-each select="lso:Type">
				<xsl:call-template name="k-9060"/>
			</xsl:for-each>&#160;<xsl:value-of select="lso:Name"/>
		</div>
	</xsl:template>
	<xsl:template match="lso:CopyDest" mode="hode">
		<xsl:apply-templates select="lso:HCP" mode="hode"/>
	</xsl:template>
	<xsl:template match="lso:Address" mode="hode">
		<xsl:if test="lso:Type and (lso:StreetAdr or lso:PostalCode or lso:City or lso:CityDistr)">
			<div class="NoPrint">&#160;<b>
					<xsl:for-each select="lso:Type">
						<xsl:call-template name="k-3401"/>
					</xsl:for-each>:&#160;</b>
			</div>
		</xsl:if>
		<xsl:if test="lso:StreetAdr">
			<div>
				<xsl:value-of select="lso:StreetAdr"/>
			</div>
		</xsl:if>
		<xsl:if test="lso:PostalCode or lso:City">
			<xsl:if test="lso:StreetAdr">
				<div class="NoPrint">,</div>
			</xsl:if>
			<div>
				<xsl:value-of select="lso:PostalCode"/>&#160;<xsl:value-of select="lso:City"/>
			</div>
		</xsl:if>
		<xsl:for-each select="lso:CityDistr">
			<div class="NoPrint">,</div>
			<div>
				<xsl:call-template name="k-3403"/>
			</div>
		</xsl:for-each>
		<xsl:for-each select="lso:County">
			<div class="NoPrint">,</div>
			<div>
				<xsl:call-template name="k-3402"/>
			</div>
		</xsl:for-each>
		<xsl:for-each select="lso:Country">
			<div class="NoPrint">,</div>
			<div>
				<xsl:call-template name="k-9043"/>
			</div>
		</xsl:for-each>
		<xsl:for-each select="lso:TeleAddress">
			<div class="NoPrint">&#160;</div>
			<xsl:apply-templates select="." mode="hode"/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="lso:TeleAddress" mode="hode">
		<div>
			<span class="strong">
				<xsl:choose>
					<xsl:when test="starts-with(@V, &quot;tel:&quot;) or starts-with(@V, &quot;callto:&quot;)">Telefon</xsl:when>
					<xsl:when test="starts-with(@V, &quot;fax:&quot;)">Faks</xsl:when>
					<xsl:when test="starts-with(@V, &quot;mailto:&quot;)">e-post</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring-before(@V, &quot;:&quot;)"/>
					</xsl:otherwise>
				</xsl:choose>
			</span>&#160;<xsl:value-of select="substring-after(@V, &quot;:&quot;)"/>&#160;
		</div>
	</xsl:template>
	<!-- Hoveddokument -->
	<xsl:template name="ResultBody">
		<div class="{$stil}">
			<xsl:variable name="position" select="position()"/>
			<!-- Tabell for rekvisisjon -->
			<h1>Rekvisisjon
				<xsl:for-each select="lso:MsgDescr">
					<xsl:call-template name="k-8202"/>
				</xsl:for-each>
				<xsl:for-each select="lso:ServType">&#160;-
					<xsl:call-template name="k-7309"/>
				</xsl:for-each>
			</h1>
			<div>
				<xsl:call-template name="FellesMeny">
					<xsl:with-param name="position" select="position()"/>
				</xsl:call-template>
			</div>
			<xsl:variable name="id1">
				<xsl:value-of select="concat('ServReq',$position)"/>
			</xsl:variable>
			<h2 id="{$id1}">Meldingsinformasjon</h2>
			<table>
				<tbody>
					<xsl:apply-templates select=".">
						<xsl:with-param name="col" select="$std-col"/>
					</xsl:apply-templates>
				</tbody>
			</table>
			<!-- Tabell for rekvirert undersøkelse -->
			<xsl:for-each select=".//lso:ReqInvestigation">
				<xsl:variable name="id2">
					<xsl:value-of select="concat('ReqInvestigation',$position,position())"/>
				</xsl:variable>
				<h2 id="{$id2}">
					<xsl:choose>
						<xsl:when test="last()!=1">
							<xsl:value-of select="concat('Rekvirert undersøkelse ',position())"/>
						</xsl:when>
						<xsl:otherwise>Rekvirert undersøkelse</xsl:otherwise>
					</xsl:choose>
					<xsl:for-each select="lso:ServType">&#160;-
						<xsl:call-template name="k-7309"/>
					</xsl:for-each>
				</h2>
				<table>
					<tbody>
						<xsl:apply-templates select=".">
							<xsl:with-param name="col" select="$std-col"/>
						</xsl:apply-templates>
					</tbody>
				</table>
			</xsl:for-each>
			<!-- Tabell for øvrig pasientinformasjon -->
			<xsl:for-each select="lso:Patient">
				<xsl:if test="lso:BasisForHealthServices or lso:Sex or lso:DateOfBirth or lso:DateOfDeath or lso:AdmLocation or lso:AdditionalId or lso:InfItem or lso:Patient">
					<xsl:variable name="id5">
						<xsl:value-of select="concat('Patient',$position)"/>
					</xsl:variable>
					<h2 id="{$id5}">Pasient</h2>
					<table>
						<tbody>
							<xsl:apply-templates select=".">
								<xsl:with-param name="col" select="$std-col"/>
							</xsl:apply-templates>
						</tbody>
					</table>
				</xsl:if>
			</xsl:for-each>
			<!-- Tabell for øvrig informasjon om undersøkelsesobjekt: dyr -->
			<xsl:for-each select="lso:Animal">
				<xsl:if test="lso:Sex or lso:Animal">
					<xsl:variable name="id6">
						<xsl:value-of select="concat('Animal',$position)"/>
					</xsl:variable>
					<h2 id="{$id6}">Undersøkelsesdyr</h2>
					<table>
						<tbody>
							<xsl:apply-templates select=".">
								<xsl:with-param name="col" select="$std-col"/>
							</xsl:apply-templates>
						</tbody>
					</table>
				</xsl:if>
			</xsl:for-each>
			<!-- Tabell for alle tilknyttede helsetjenesteenheter -->
			<xsl:variable name="id7">
				<xsl:value-of select="concat('HCP',$position)"/>
			</xsl:variable>
			<h2 id="{$id7}">Helsetjenesteenheter</h2>
			<table>
				<tbody>
					<xsl:for-each select="lso:ServProvider | lso:Requester | lso:PaymentResponsible | lso:CopyDest | .//lso:ResponsibleHcp | lso:Patient/lso:AdmLocation">
						<xsl:apply-templates select=".">
							<xsl:with-param name="col" select="$std-col"/>
						</xsl:apply-templates>
					</xsl:for-each>
				</tbody>
			</table>
			<!-- Tabell for vedlegg -->
			<xsl:if test="lso:RefDoc">
				<xsl:variable name="id8">
					<xsl:value-of select="concat('RefDoc',$position)"/>
				</xsl:variable>
				<h2 id="{$id8}">Vedlegg</h2>
				<table>
					<tbody>
						<xsl:for-each select="lso:RefDoc">
							<xsl:apply-templates select=".">
								<xsl:with-param name="col" select="$std-col"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
		</div>
	</xsl:template>
	<!-- Meldingshodet - dokumentopplysninger -->
	<xsl:template name="Footer">
		<div class="{$stil}">
			<h2 style="margin-top:0px;">Dokumentinformasjon</h2>
			<table>
				<tbody>
					<tr>
						<th>Melding&#160;sendt</th>
						<td width="{$std-td}px">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../lso:GenDate/@V"/>
							</xsl:call-template>
						</td>
						<th>Meldingsid</th>
						<td>
							<xsl:value-of select="../lso:MsgId"/>
						</td>
					</tr>
					<tr>
						<th>Visningsversjon</th>
						<td colspan="3">
							<xsl:value-of select="$versjon"/>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
	</xsl:template>
	<!-- Klikkbar horisontal meny som leder lenger ned i dokumentet -->
	<xsl:template name="FellesMeny">
		<xsl:param name="position"/>
		<div id="FellesMeny" class="FellesMeny">
			<div class="NoPrint">
				<ul>
					<li>
						<xsl:variable name="temp1" select="concat('ServReq',$position)"/>
						<a href="#{$temp1}">Meldingsinformasjon</a>
					</li>
					<xsl:for-each select=".//lso:ReqInvestigation">
						<li>
							<xsl:variable name="temp2" select="concat('ReqInvestigation',$position,position())"/>
							<xsl:choose>
								<xsl:when test="last()!=1">
									<a href="#{$temp2}">
										<xsl:value-of select="concat('Rekvirert undersøkelse',position())"/>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<a href="#{$temp2}">Rekvirert undersøkelse</a>
								</xsl:otherwise>
							</xsl:choose>
						</li>
					</xsl:for-each>
					<xsl:if test=".//lso:Patient/lso:BasisForHealthServices or .//lso:Patient/lso:Sex or .//lso:Patient/lso:DateOfBirth or .//lso:Patient/lso:DateOfDeath or .//lso:Patient/lso:AdmLocation or .//lso:Patient/lso:AdditionalId or .//lso:Patient/lso:InfItem or .//lso:Patient/lso:Patient">
						<li>
							<xsl:variable name="temp3" select="concat('Patient',$position)"/>
							<a href="#{$temp3}">Pasient</a>
						</li>
					</xsl:if>
					<xsl:if test=".//lso:Animal/lso:Sex or .//lso:Animal/lso:Animal">
						<li>
							<xsl:variable name="temp4" select="concat('Animal',$position)"/>
							<a href="#{$temp4}">Undersøkelsesdyr</a>
						</li>
					</xsl:if>
					<xsl:if test=".//lso:ServProvider | .//lso:Requester | .//lso:PaymentResponsible | .//lso:CopyDest | .//lso:ResponsibleHcp | .//lso:Patient/lso:AdmLocation">
						<li>
							<xsl:variable name="temp5" select="concat('HCP',$position)"/>
							<a href="#{$temp5}">Helsetjenesteenheter</a>
						</li>
					</xsl:if>
					<xsl:if test=".//lso:RefDoc">
						<li>
							<xsl:variable name="temp6" select="concat('RefDoc',$position)"/>
							<a href="#{$temp6}">Vedlegg</a>
						</li>
					</xsl:if>
				</ul>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="lso:ServReq">
		<xsl:param name="col"/>
		<xsl:if test="lso:IssueDate or lso:RequestedDateReport or lso:RequestedPrioReport or lso:PaymentCat or lso:Reservation">
			<tr>
				<xsl:if test="lso:IssueDate">
					<th>Utstedt-dato</th>
					<td width="{((($col)-2)*number(not(lso:RequestedDateReport | lso:RequestedPrioReport | lso:PaymentCat | lso:Reservation))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lso:RequestedDateReport | lso:RequestedPrioReport | lso:PaymentCat | lso:Reservation))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="lso:IssueDate/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="lso:RequestedDateReport">
					<th>Ønsket svartid</th>
					<td width="{((($col)-2-count(lso:IssueDate)*2)*number(not(lso:RequestedPrioReport | lso:PaymentCat | lso:Reservation))+1)*$std-td}px" colspan="{(($col)-2-count(lso:IssueDate)*2)*number(not(lso:RequestedPrioReport | lso:PaymentCat | lso:Reservation))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="lso:RequestedDateReport/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="lso:RequestedPrioReport">
					<th>Ønsket prioritet</th>
					<td width="{((($col)-2-count(lso:IssueDate | lso:RequestedDateReport)*2)*number(not(lso:PaymentCat | lso:Reservation))+1)*$std-td}px" colspan="{(($col)-2-count(lso:IssueDate | lso:RequestedDateReport)*2)*number(not(lso:PaymentCat | lso:Reservation))+1}">
						<xsl:for-each select="lso:RequestedPrioReport">
							<xsl:call-template name="k-8115"/>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="lso:PaymentCat">
					<th>Betalingskategori</th>
					<td width="{((($col)-2-count(lso:IssueDate | lso:RequestedDateReport | lso:RequestedPrioReport)*2)*number(not(lso:Reservation))+1)*$std-td}px" colspan="{(($col)-2-count(lso:IssueDate | lso:RequestedDateReport | lso:RequestedPrioReport)*2)*number(not(lso:Reservation))+1}">
						<xsl:for-each select="lso:PaymentCat">
							<xsl:call-template name="k-4101"/>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="lso:Reservation">
					<th>Pasientens reservasjoner</th>
					<td colspan="{($col)-1-count(lso:IssueDate | lso:RequestedDateReport | lso:RequestedPrioReport | lso:PaymentCat)*2}">
						<xsl:for-each select="lso:Reservation">
							<div>
								<xsl:call-template name="k-3108"/>
							</div>
						</xsl:for-each>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="lso:NoReport or lso:LevelOfDetail or lso:EscortRequired">
			<tr>
				<xsl:if test="lso:NoReport">
					<th>Ønsker svar</th>
					<td width="{((($col)-2)*number(not(lso:LevelOfDetail | lso:EscortRequired))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lso:LevelOfDetail | lso:EscortRequired))+1}">
						<xsl:choose>
							<xsl:when test="lso:NoReport/@V=&quot;false&quot;">Ja</xsl:when>
							<xsl:otherwise>Nei</xsl:otherwise>
						</xsl:choose>
					</td>
				</xsl:if>
				<xsl:if test="lso:LevelOfDetail">
					<th>Ønsket detaljnivå</th>
					<td width="{((($col)-2-count(lso:NoReport)*2)*number(not(lso:EscortRequired))+1)*$std-td}px" colspan="{(($col)-2-count(lso:NoReport)*2)*number(not(lso:EscortRequired))+1}">
						<xsl:apply-templates select="lso:LevelOfDetail"/>
					</td>
				</xsl:if>
				<xsl:if test="lso:EscortRequired">
					<th>Ledsagelsesbehov</th>
					<td colspan="{(($col)-1-count(lso:NoReport | lso:LevelOfDetail)*2)}">
						<xsl:for-each select="lso:EscortRequired">
							<xsl:call-template name="k-8247"/>
						</xsl:for-each>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="lso:ReqComment">
			<tr>
				<th>Rekvirentens kommentar</th>
				<td colspan="{($col)-1}">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="lso:ReqComment"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="lso:ReasonAsText">
			<tr>
				<th colspan="{$col}" class="h3">Begrunnelser</th>
			</tr>
			<xsl:apply-templates select="lso:ReasonAsText">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:if>
		<xsl:if test="lso:Comment">
			<tr>
				<th colspan="{$col}" class="h3">Kommentarer</th>
			</tr>
			<xsl:apply-templates select="lso:Comment">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	<xsl:template match="lso:ReqInvestigation">
		<xsl:param name="col"/>
		<xsl:if test="lso:Purpose or lso:ReqDate or lso:Priority">
			<tr>
				<xsl:if test="lso:Purpose">
					<th>Formål</th>
					<td width="{((($col)-2)*number(not(lso:ReqDate | lso:Priority))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lso:ReqDate | lso:Priority))+1}">
						<xsl:for-each select="lso:Purpose">
							<xsl:call-template name="k-8248"/>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="lso:ReqDate">
					<th>Ønsket tidspunkt</th>
					<td width="{((($col)-2-count(lso:Purpose)*2)*number(not(lso:Priority))+1)*$std-td}px" colspan="{(($col)-2-count(lso:Purpose)*2)*number(not(lso:Priority))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="lso:ReqDate/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="lso:Priority">
					<th>Hastegrad</th>
					<td colspan="{($col)-1-count(lso:Purpose | lso:ReqDate)*2}">
						<xsl:for-each select="lso:Priority">
							<xsl:call-template name="k-8304"/>
						</xsl:for-each>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="lso:Comment">
			<tr>
				<th>Kommentar</th>
				<td colspan="{($col)-1}">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="lso:Comment"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="lso:Investigation">
			<tr>
				<th colspan="{$col}" class="h3">Undersøkelse</th>
			</tr>
			<xsl:for-each select="lso:Investigation">
				<xsl:if test="lso:Id or lso:Spec or lso:Comment or lso:Priority">
					<tr>
						<xsl:if test="lso:Id">
							<th>Type</th>
							<td width="{((($col)-2)*number(not(lso:Spec | lso:Comment | lso:Priority))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lso:Spec | lso:Comment | lso:Priority))+1}">
								<xsl:for-each select="lso:Id">
									<xsl:choose>
										<xsl:when test="contains(@S, '8219')">
											<xsl:call-template name="k-8219"/>
										</xsl:when>
										<xsl:when test="contains(@S, '8220')">
											<xsl:call-template name="k-8220"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="k-dummy"/>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:if test="position()!=last()">,&#160;</xsl:if>
								</xsl:for-each>
							</td>
						</xsl:if>
						<xsl:if test="lso:Spec">
							<th>Spesifisert</th>
							<td width="{((($col)-2-number(boolean(lso:Id))*2-number(boolean(lso:Spec))*2)*number(not(lso:Comment | lso:Priority))+1)*$std-td}px" colspan="{(($col)-2-number(boolean(lso:Id))*2-number(boolean(lso:Spec))*2)*number(not(lso:Comment | lso:Priority))+1}">
								<xsl:for-each select="lso:Spec">
									<xsl:call-template name="k-dummy"/>
									<xsl:if test="position()!=last()">,&#160;</xsl:if>
								</xsl:for-each>
							</td>
						</xsl:if>
						<xsl:if test="lso:Comment">
							<th>Kommentar</th>
							<td width="{((($col)-2-number(boolean(lso:Id))*2-number(boolean(lso:Spec))*2)*number(not(lso:Priority))+1)*$std-td}px" colspan="{(($col)-2-number(boolean(lso:Id))*2-number(boolean(lso:Spec))*2)*number(not(lso:Priority))+1}">
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="lso:Comment"/>
								</xsl:call-template>
							</td>
						</xsl:if>
						<xsl:if test="lso:Priority">
							<th>Hastegrad</th>
							<td colspan="{($col)-1-number(boolean(lso:Id))*2-number(boolean(lso:Spec))*2-count(lso:Comment)*2}">
								<xsl:for-each select="lso:Priority">
									<xsl:call-template name="k-8304"/>
								</xsl:for-each>
							</td>
						</xsl:if>
					</tr>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="lso:StandingInv">
			<tr>
				<th class="h3">Gjentagende undersøkelse</th>
			</tr>
			<xsl:for-each select="lso:StandingInv">
				<xsl:if test="lso:NumberOfTimes or lso:ScheduledStart or lso:ScheduledEnd or lso:CycleTime or lso:EndCondition">
					<tr>
						<xsl:if test="lso:NumberOfTimes">
							<th>Antall repetisjoner</th>
							<td width="{((($col)-2)*number(not(lso:ScheduledStart | lso:ScheduledEnd | lso:CycleTime | lso:EndCondition))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lso:ScheduledStart | lso:ScheduledEnd | lso:CycleTime | lso:EndCondition))+1}">
								<xsl:value-of select="lso:NumberOfTimes"/>
							</td>
						</xsl:if>
						<xsl:if test="lso:ScheduledStart">
							<th>Planlagt start</th>
							<td width="{((($col)-2-count(lso:NumberOfTimes)*2)*number(not(lso:ScheduledEnd | lso:CycleTime | lso:EndCondition))+1)*$std-td}px" colspan="{(($col)-2-count(lso:NumberOfTimes)*2)*number(not(lso:ScheduledEnd | lso:CycleTime | lso:EndCondition))+1}">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="lso:ScheduledStart/@V"/>
								</xsl:call-template>
							</td>
						</xsl:if>
						<xsl:if test="lso:ScheduledEnd">
							<th>Planlagt slutt</th>
							<td width="{((($col)-2-count(lso:NumberOfTimes | lso:ScheduledStart)*2)*number(not(lso:CycleTime | lso:EndCondition))+1)*$std-td}px" colspan="{(($col)-2-count(lso:NumberOfTimes | lso:ScheduledStart)*2)*number(not(lso:CycleTime | lso:EndCondition))+1}">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="lso:ScheduledEnd/@V"/>
								</xsl:call-template>
							</td>
						</xsl:if>
						<xsl:if test="lso:CycleTime">
							<th>Intervall</th>
							<td width="{((($col)-2-count(lso:NumberOfTimes | lso:ScheduledStart | lso:ScheduledEnd)*2)*number(not(lso:EndCondition))+1)*$std-td}px" colspan="{(($col)-2-count(lso:NumberOfTimes | lso:ScheduledStart | lso:ScheduledEnd)*2)*number(not(lso:EndCondition))+1}">
								<xsl:value-of select="lso:CycleTime"/>
							</td>
						</xsl:if>
						<xsl:if test="lso:EndCondition">
							<th>Sluttbetingelser</th>
							<td colspan="{($col)-1-count(lso:NumberOfTimes | lso:ScheduledStart | lso:ScheduledEnd | lso:CycleTime)*2}">
								<xsl:value-of select="lso:EndCondition"/>
							</td>
						</xsl:if>
					</tr>
				</xsl:if>
				<xsl:if test="lso:Instructions">
					<tr>
						<th>Instruksjon</th>
						<td colspan="{($col)-1}">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="lso:Instructions"/>
							</xsl:call-template>
						</td>
					</tr>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="lso:AnalysedSubject">
			<tr>
				<th colspan="{$col}" class="h3">Prøve</th>
			</tr>
			<xsl:for-each select="lso:AnalysedSubject">
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
					<xsl:with-param name="pos" select="position()"/>
					<xsl:with-param name="last" select="last()"/>
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	<xsl:template match="lso:Comment">
		<xsl:param name="col"/>
		<xsl:if test="lso:Heading or lso:TextResultValue or lso:TextCode">
			<tr>
				<th>
					<xsl:choose>
						<xsl:when test="lso:Heading">
							<xsl:for-each select="lso:Heading">
								<xsl:call-template name="k-8234"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:when test="contains(lso:TextCode/@S,'8274')">Anbefaling om supplerende undersøkelse</xsl:when>
						<xsl:otherwise>Generell</xsl:otherwise>
					</xsl:choose>
				</th>
				<td colspan="{($col)-1}">
					<xsl:if test="lso:TextResultValue">
						<div>
							<xsl:value-of select="lso:TextResultValue"/>
						</div>
					</xsl:if>
					<xsl:for-each select="lso:TextCode">
						<xsl:choose>
							<xsl:when test="contains(@S,'8274')">
								<xsl:call-template name="k-8274"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="k-dummy"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
	<xsl:template match="lso:ReasonAsText">
		<xsl:param name="col"/>
		<xsl:if test="lso:Heading or lso:TextResultValue">
			<tr>
				<th>
					<xsl:for-each select="lso:Heading">
						<xsl:call-template name="k-8231"/>
					</xsl:for-each>
				</th>
				<td colspan="{($col)-1}">
					<xsl:for-each select="lso:TextResultValue">
						<xsl:choose>
							<xsl:when test="count(child::*)=0">
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="."/>
								</xsl:call-template>&#160;
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="node()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
	<xsl:template match="lso:Patient">
		<xsl:param name="col"/>
		<tr>
			<th>Navn&#160;<xsl:if test="lso:Relation and local-name(..)=&quot;Patient&quot;">-&#160;relasjon:&#160;<xsl:for-each select="lso:Relation">
						<xsl:call-template name="k-8238"/>
					</xsl:for-each>
				</xsl:if>
			</th>
			<td width="{$std-td}px">
				<xsl:value-of select="lso:Name"/>
			</td>
			<th>
				<xsl:for-each select="lso:TypeOffId">
					<xsl:call-template name="k-8116"/>
				</xsl:for-each>
			</th>
			<td width="{((($col)-2-count(lso:Name)*2)*number(not(lso:Sex | lso:DateOfBirth | lso:DateOfDeath))+1)*$std-td}px" colspan="{(($col)-2-count(lso:Name)*2)*number(not(lso:Sex | lso:DateOfBirth | lso:DateOfDeath))+1}">
				<xsl:value-of select="lso:OffId"/>
			</td>
			<xsl:if test="lso:Sex">
				<th>Kjønn</th>
				<td width="{((($col)-2-count(lso:Name | lso:OffId)*2)*number(not(lso:DateOfBirth | lso:DateOfDeath))+1)*$std-td}px" colspan="{(($col)-2-count(lso:Name | lso:OffId)*2)*number(not(lso:DateOfBirth | lso:DateOfDeath))+1}">
					<xsl:for-each select="lso:Sex">
						<xsl:call-template name="k-3101"/>
					</xsl:for-each>
				</td>
			</xsl:if>
			<xsl:if test="lso:DateOfBirth">
				<th>Fødselsdato</th>
				<td width="{((($col)-2-count(lso:Name | lso:OffId | lso:Sex)*2)*number(not(lso:DateOfDeath))+1)*$std-td}px" colspan="{(($col)-2-count(lso:Name | lso:OffId | lso:Sex)*2)*number(not(lso:DateOfDeath))+1}">
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="lso:DateOfBirth/@V"/>
					</xsl:call-template>
				</td>
			</xsl:if>
			<xsl:if test="lso:DateOfDeath">
				<th>Dødsdato</th>
				<td colspan="{(($col)-1-count(lso:Name | lso:OffId | lso:Sex | lso:DateOfBirth)*2)}">
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="lso:DateOfDeath/@V"/>
					</xsl:call-template>
				</td>
			</xsl:if>
		</tr>
		<xsl:for-each select="lso:Address">
			<xsl:variable name="antall-tel" select="count(lso:TeleAddress)"/>
			<tr>
				<xsl:apply-templates select="lso:TeleAddress">
					<xsl:with-param name="col" select="(($col)-1)*number(not(lso:Type and (lso:PostalCode or lso:City)))+1"/>
				</xsl:apply-templates>
				<xsl:if test="lso:Type and (lso:PostalCode or lso:City)">
					<xsl:apply-templates select=".">
						<xsl:with-param name="col" select="($col)-1-($antall-tel)*2"/>
					</xsl:apply-templates>
				</xsl:if>
			</tr>
		</xsl:for-each>
		<xsl:if test="lso:AdditionalId or lso:BasisForHealthServices">
			<xsl:variable name="antall-id" select="count(lso:AdditionalId)"/>
			<tr>
				<xsl:choose>
					<xsl:when test="lso:AdditionalId and lso:BasisForHealthServices">
						<th colspan="2">Andre pasient-identifikatorer</th>
						<xsl:for-each select="lso:AdditionalId">
							<xsl:apply-templates select=".">
								<xsl:with-param name="col">
									<xsl:choose>
										<xsl:when test="position() = $antall-id">
											<xsl:value-of select="($col)-3-($antall-id)*2"/>
										</xsl:when>
										<xsl:otherwise>1</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
							</xsl:apply-templates>
						</xsl:for-each>
						<th>Refusjonsgrunnlag</th>
						<td>
							<xsl:for-each select="lso:BasisForHealthServices">
								<xsl:call-template name="k-8246"/>
							</xsl:for-each>
						</td>
					</xsl:when>
					<xsl:when test="lso:AdditionalId and not(lso:BasisForHealthServices)">
						<th colspan="2">Andre pasient-identifikatorer</th>
						<xsl:for-each select="lso:AdditionalId">
							<xsl:apply-templates select=".">
								<xsl:with-param name="col">
									<xsl:choose>
										<xsl:when test="position() = $antall-id">
											<xsl:value-of select="($col)-1-($antall-id)*2"/>
										</xsl:when>
										<xsl:otherwise>1</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
							</xsl:apply-templates>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<th>Refusjonsgrunnlag</th>
						<td colspan="{($col)-1}">
							<xsl:for-each select="lso:BasisForHealthServices">
								<xsl:call-template name="k-8246"/>
							</xsl:for-each>
						</td>
					</xsl:otherwise>
				</xsl:choose>
			</tr>
		</xsl:if>
		<xsl:for-each select="lso:AdmLocation">
			<tr>
				<th colspan="{$col}" class="h3">
					Opphold
				</th>
			</tr>
			<tr>
				<th>Institusjon</th>
				<td width="{((($col)-2)*number(not(lso:AdmCat | lso:StartDateTime | lso:EndDateTime))+1)*$std-td}px" colspan="{(($col)-4)*number(not(lso:AdmCat | lso:StartDateTime | lso:EndDateTime))+3}">
					<!-- Gir her boksen en default kolonnebredde på 3 mot normalt 1 -->
					<xsl:value-of select="lso:Location/lso:Inst/lso:Name"/>
					<xsl:if test="lso:Location/lso:Inst/lso:Dept/lso:Name">
						<xsl:for-each select="lso:Location/lso:Inst/lso:Dept">,&#160;<xsl:value-of select="lso:Name"/>
						</xsl:for-each>
					</xsl:if>
					<xsl:for-each select="lso:Location/lso:SubLocation">,&#160;<xsl:for-each select="lso:Type">
							<xsl:call-template name="k-8242"/>
						</xsl:for-each>:&#160;<xsl:value-of select="lso:Place"/>
					</xsl:for-each>
				</td>
				<xsl:if test="lso:AdmCat">
					<th>Type&#160;tjeneste&#160;</th>
					<td width="{((($col)-6)*number(not(lso:StartDateTime | lso:EndDateTime))+1)*$std-td}px" colspan="{(($col)-6)*number(not(lso:StartDateTime | lso:EndDateTime))+1}">
						<xsl:for-each select="lso:AdmCat">
							<xsl:call-template name="k-8240"/>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="lso:StartDateTime">
					<th>Innlagt&#160;dato&#160;</th>
					<td width="{((($col)-6-count(lso:AdmCat)*2)*number(not(lso:EndDateTime))+1)*$std-td}px" colspan="{(($col)-6-count(lso:AdmCat)*2)*number(not(lso:EndDateTime))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="lso:StartDateTime/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="lso:EndDateTime">
					<th>Utskrevet&#160;dato&#160;</th>
					<td colspan="{(($col)-5-count(lso:AdmCat | lso:StartDateTime)*2)}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="lso:EndDateTime/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="lso:Patient | lso:InfItem">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="lso:Animal">
		<xsl:param name="col"/>
		<tr>
			<xsl:if test="lso:NameOwner">
				<th>Eier&#160;</th>
				<td width="{((($col)-2)*number(not(lso:Name | lso:Sex | lso:Species))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lso:Name | lso:Sex | lso:Species))+1}">
					<xsl:value-of select="lso:NameOwner"/>
				</td>
			</xsl:if>
			<xsl:if test="lso:Name">
				<th>Navn&#160;
					<xsl:if test="local-name(..)=&quot;Animal&quot;">
						-&#160;relasjon:&#160;<xsl:for-each select="lso:Relation">
							<xsl:call-template name="k-8238"/>
						</xsl:for-each>
					</xsl:if>
				</th>
				<td width="{((($col)-2-count(lso:NameOwner)*2)*number(not(lso:Sex | lso:Species))+1)*$std-td}px" colspan="{(($col)-2-count(lso:NameOwner)*2)*number(not(lso:Sex | lso:Species))+1}">
					<xsl:value-of select="lso:Name"/>
				</td>
			</xsl:if>
			<xsl:if test="lso:Sex">
				<th>Kjønn</th>
				<td width="{((($col)-2-count(lso:NameOwner | lso:Name)*2)*number(not(lso:Species))+1)*$std-td}px" colspan="{(($col)-2-count(lso:NameOwner | lso:Name)*2)*number(not(lso:Species))+1}">
					<xsl:for-each select="lso:Sex">
						<xsl:call-template name="k-3101"/>
					</xsl:for-each>
				</td>
			</xsl:if>
			<xsl:if test="lso:Species">
				<th>Art</th>
				<td colspan="{($col)-1-count(lso:NameOwner | lso:Name | lso:Sex)*2}">
					<xsl:value-of select="lso:Species"/>
				</td>
			</xsl:if>
		</tr>
		<xsl:if test="lso:Animal">
			<xsl:apply-templates select="lso:Animal">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	<xsl:template match="lso:AnalysedSubject">
		<xsl:param name="col"/>
		<xsl:param name="pos"/>
		<xsl:param name="last"/>
		<xsl:if test="lso:Type or lso:TypeCoded or lso:IdByRequester or lso:RequestedSubject or lso:CollectedSample or lso:CollectedStudyProduct">
			<tr>
				<xsl:if test="lso:Type or lso:TypeCoded">
					<th>Type materiale<xsl:if test="$last!=1">&#160;<xsl:value-of select="$pos"/>
						</xsl:if>
					</th>
					<td width="{((($col)-2)*number(not(lso:IdByRequester | lso:RequestedSubject | lso:CollectedSample | lso:CollectedStudyProduct))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lso:IdByRequester | lso:RequestedSubject | lso:CollectedSample | lso:CollectedStudyProduct))+1}">
						<!--Kommentar til en tilsynelatende for lang kolonnebredde: RequestedSubject, CollectedSample og CollectedStudyProduct er innenfor en choice -->
						<xsl:choose>
							<xsl:when test="lso:Type">
								<xsl:value-of select="lso:Type"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="lso:TypeCoded">
									<xsl:choose>
										<xsl:when test="contains(@S, '8216')">
											<xsl:call-template name="k-8216"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="k-dummy"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</td>
				</xsl:if>
				<xsl:if test="lso:IdByRequester">
					<th>Rekvirents id</th>
					<td width="{((($col)-2-number(boolean(../lso:Type or ../lso:TypeCoded))*2)*number(not(lso:RequestedSubject | lso:CollectedSample | lso:CollectedStudyProduct))+1)*$std-td}px" colspan="{(($col)-2-number(boolean(../lso:Type or ../lso:TypeCoded))*2)*number(not(lso:RequestedSubject | lso:CollectedSample | lso:CollectedStudyProduct))+1}">
						<xsl:value-of select="lso:IdByRequester"/>
					</td>
				</xsl:if>
				<xsl:for-each select="lso:RequestedSubject">
					<xsl:if test="lso:Priority">
						<th>Prøvetakingsprioritet</th>
						<td width="{((($col)-2-number(boolean(../lso:Type or ../lso:TypeCoded))*2-count(../lso:IdByRequester)*2)*number(not(lso:ReqDate))+1)*$std-td}px" colspan="{(($col)-2-number(boolean(../lso:Type or ../lso:TypeCoded))*2-count(../lso:IdByRequester)*2)*number(not(lso:ReqDate))+1}">
							<xsl:for-each select="lso:Priority">
								<xsl:call-template name="k-8304"/>
							</xsl:for-each>
						</td>
					</xsl:if>
					<xsl:if test="lso:ReqDate">
						<th>Ønsket tidspunkt</th>
						<td colspan="{($col)-1-number(boolean(../lso:Type or ../lso:TypeCoded))*2-count(../lso:IdByRequester | lso:Priority)*2}">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="lso:ReqDate/@V"/>
							</xsl:call-template>
						</td>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="lso:CollectedSample">
					<xsl:if test="lso:CollectedDate">
						<th>Prøve tatt - dato</th>
						<td width="{((($col)-2-number(boolean(../lso:Type or ../lso:TypeCoded))*2-count(../lso:IdByRequester)*2)*number(not(lso:CollectorComment | lso:CollectorCommentCoded | lso:Logistics))+1)*$std-td}px" colspan="{(($col)-2-number(boolean(../lso:Type or ../lso:TypeCoded))*2-count(../lso:IdByRequester)*2)*number(not(lso:CollectorComment | lso:CollectorCommentCoded | lso:Logistics))+1}">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="lso:CollectedDate/@V"/>
							</xsl:call-template>
						</td>
					</xsl:if>
					<xsl:if test="lso:Logistics">
						<th>Forsendelsesmåte</th>
						<td width="{((($col)-2-number(boolean(../lso:Type or ../lso:TypeCoded))*2-count(../lso:IdByRequester | lso:CollectedDate)*2)*number(not(lso:CollectorComment | lso:CollectorCommentCoded))+1)*$std-td}px" colspan="{(($col)-2-number(boolean(../lso:Type or ../lso:TypeCoded))*2-count(../lso:IdByRequester | lso:CollectedDate)*2)*number(not(lso:CollectorComment | lso:CollectorCommentCoded))+1}">
							<xsl:value-of select="lso:Logistics"/>
						</td>
					</xsl:if>
					<xsl:if test="lso:CollectorComment or lso:CollectorCommentCoded">
						<th>Prøvetakers kommentar</th>
						<td colspan="{($col)-1-number(boolean(../lso:Type or ../lso:TypeCoded))*2-count(../lso:IdByRequester | lso:CollectedDate | lso:Logistics)*2}">
							<xsl:if test="lso:CollectorComment">
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="lso:CollectorComment"/>
								</xsl:call-template>&#160;
							</xsl:if>
							<xsl:for-each select="lso:CollectorCommentCoded">
								<xsl:choose>
									<xsl:when test="contains(@S, '8275')">
										<xsl:call-template name="k-8275"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="k-dummy"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</td>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="lso:CollectedStudyProduct">
					<xsl:if test="lso:Type">
						<th>Type analyseprodukt</th>
						<td width="{((($col)-2-number(boolean(../lso:Type or ../lso:TypeCoded))*2-count(../lso:IdByRequester)*2)*number(not(lso:ProducedDate | lso:RefRelatedProd))+1)*$std-td}px" colspan="{(($col)-2-number(boolean(../lso:Type or ../lso:TypeCoded))*2-count(../lso:IdByRequester)*2)*number(not(lso:ProducedDate | lso:RefRelatedProd))+1}">
							<xsl:value-of select="lso:Type"/>
						</td>
					</xsl:if>
					<xsl:if test="lso:ProducedDate">
						<th>Avledet prøve tatt - dato</th>
						<td width="{((($col)-2-number(boolean(../lso:Type or ../lso:TypeCoded))*2-count(../lso:IdByRequester | lso:Type)*2)*number(not(lso:RefRelatedProd))+1)*$std-td}px" colspan="{(($col)-2-number(boolean(../lso:Type or ../lso:TypeCoded))*2-count(../lso:IdByRequester | lso:Type)*2)*number(not(lso:RefRelatedProd))+1}">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="lso:ProducedDate/@V"/>
							</xsl:call-template>
						</td>
					</xsl:if>
					<xsl:if test="lso:RefRelatedProd">
						<th>Referanse til relatert produkt</th>
						<td colspan="{($col)-1-number(boolean(../lso:Type or ../lso:TypeCoded))*2-count(../lso:IdByRequester | lso:Type | lso:ProducedDate)*2}">
							<xsl:value-of select="lso:RefRelatedProd"/>
						</td>
					</xsl:if>
				</xsl:for-each>
			</tr>
		</xsl:if>
		<xsl:if test="lso:Number or lso:IdByServProv or lso:SampleCollInd or lso:SampleCollProc">
			<tr>
				<xsl:if test="lso:Number">
					<th>Antall</th>
					<td width="{((($col)-2)*number(not(lso:IdByServProv | lso:SampleCollInd | lso:SampleCollProc))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lso:IdByServProv | lso:SampleCollInd | lso:SampleCollProc))+1}">
						<xsl:value-of select="lso:Number"/>
					</td>
				</xsl:if>
				<xsl:if test="lso:IdByServProv">
					<th>Mottakers id</th>
					<td width="{((($col)-2-count(lso:Number)*2)*number(not(lso:SampleCollInd | lso:SampleCollProc))+1)*$std-td}px" colspan="{(($col)-2-count(lso:Number)*2)*number(not(lso:SampleCollInd | lso:SampleCollProc))+1}">
						<xsl:value-of select="lso:IdByServProv"/>
					</td>
				</xsl:if>
				<xsl:if test="lso:SampleCollInd">
					<th>Prøve tatt</th>
					<td width="{((($col)-2-count(lso:Number | lso:IdByServProv)*2)*number(not(lso:SampleCollProc))+1)*$std-td}px" colspan="{(($col)-2-count(lso:Number | lso:IdByServProv)*2)*number(not(lso:SampleCollProc))+1}">
						<xsl:for-each select="lso:SampleCollInd">
							<xsl:call-template name="k-1101"/>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="lso:SampleCollProc">
					<th>Prøvetakingsprosedyre</th>
					<td colspan="{($col)-1-count(lso:Number | lso:IdByServProv | lso:SampleCollInd)*2}">
						<xsl:for-each select="lso:SampleCollProc">
							<xsl:call-template name="k-dummy"/>
						</xsl:for-each>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="lso:AnatomicalOrigin or lso:PreservMaterial or lso:Pretreatment or lso:SubjectMeasures">
			<tr>
				<xsl:if test="lso:AnatomicalOrigin">
					<th>Anatomisk lokasjon</th>
					<td width="{((($col)-2)*number(not(lso:PreservMaterial | lso:Pretreatment | lso:SubjectMeasures))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lso:PreservMaterial | lso:Pretreatment | lso:SubjectMeasures))+1}">
						<xsl:value-of select="lso:AnatomicalOrigin"/>
					</td>
				</xsl:if>
				<xsl:if test="lso:PreservMaterial">
					<th>Konserverings-middel</th>
					<td width="{((($col)-2-count(lso:AnatomicalOrigin)*2)*number(not(lso:Pretreatment | lso:SubjectMeasures))+1)*$std-td}px" colspan="{(($col)-2-count(lso:AnatomicalOrigin)*2)*number(not(lso:Pretreatment | lso:SubjectMeasures))+1}">
						<xsl:value-of select="lso:PreservMaterial"/>
					</td>
				</xsl:if>
				<xsl:if test="lso:Pretreatment">
					<th>Forberedende behandling</th>
					<td width="{((($col)-2-count(lso:AnatomicalOrigin | lso:PreservMaterial)*2)*number(not(lso:SubjectMeasures))+1)*$std-td}px" colspan="{(($col)-2-count(lso:AnatomicalOrigin | lso:PreservMaterial)*2)*number(not(lso:SubjectMeasures))+1}">
						<xsl:for-each select="lso:Pretreatment/lso:Heading">
							<xsl:call-template name="k-8232"/>
						</xsl:for-each>
						<xsl:if test="lso:Pretreatment/lso:TextResultValue">
							<div>
								<span class="strong">Beskrivelse:&#160;</span>
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="lso:Pretreatment/lso:TextResultValue"/>
								</xsl:call-template>
							</div>
						</xsl:if>
					</td>
				</xsl:if>
				<xsl:if test="lso:SubjectMeasures">
					<th>Størrelse</th>
					<td colspan="{($col)-1-count(lso:AnatomicalOrigin | lso:PreservMaterial | lso:Pretreatment)*2}">
						<xsl:for-each select="lso:SubjectMeasures">
							<div>
								<span class="strong">
									<xsl:value-of select="lso:TypeQuantity"/>:&#160;</span>
								<xsl:value-of select="lso:Quantity/@V"/>&#160;<xsl:value-of select="lso:Quantity/@U"/>&#160;
							</div>
						</xsl:for-each>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="lso:SampleHandling">
			<tr>
				<th>Håndteringsbeskrivelse</th>
				<td colspan="{($col)-1}">
					<xsl:for-each select="lso:SampleHandling">
						<div>
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="."/>
							</xsl:call-template>
						</div>
					</xsl:for-each>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="lso:Comment">
			<tr>
				<th>Kommentar</th>
				<td colspan="{($col)-1}">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="lso:Comment"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
		<xsl:for-each select="lso:AnalysedSubject">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="lso:InfItem">
		<xsl:param name="col"/>
		<xsl:variable name="type" select="lso:Type/@V"/>
		<xsl:if test="not(preceding-sibling::lso:InfItem[lso:Type/@V=$type])">
			<tr>
				<th colspan="{$col}" class="h3">
					<xsl:for-each select="lso:Type">
						<xsl:call-template name="k-8233"/>
					</xsl:for-each>
				</th>
			</tr>
		</xsl:if>
		<xsl:if test="lso:Observation/lso:Description or lso:Observation/lso:CodedDescr or lso:StartDateTime or lso:EndDateTime or lso:OrgDate">
			<tr>
				<xsl:if test="lso:Observation/lso:Description or lso:Observation/lso:CodedDescr">
					<th>Beskrivelse</th>
					<td width="{((($col)-2)*number(not(lso:StartDateTime | lso:EndDateTime | lso:OrgDate))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lso:StartDateTime | lso:EndDateTime | lso:OrgDate))+1}">
						<xsl:for-each select="lso:Observation/lso:Description">
							<xsl:choose>
								<xsl:when test="count(child::*)=0">
									<xsl:call-template name="line-breaks">
										<xsl:with-param name="text" select="."/>
									</xsl:call-template>&#160;
								</xsl:when>
								<xsl:otherwise>
									<xsl:copy-of select="node()"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
						<xsl:if test="lso:Observation/lso:CodedDescr">
							<div>
								<xsl:for-each select="lso:Observation/lso:CodedDescr">
									<xsl:choose>
										<xsl:when test="contains(@S, '8209')">
											<xsl:call-template name="k-8209"/>
										</xsl:when>
										<xsl:when test="contains(@S, '8210')">
											<xsl:call-template name="k-8210"/>
										</xsl:when>
										<xsl:when test="contains(@S, '8217')">
											<xsl:call-template name="k-8217"/>
										</xsl:when>
										<xsl:when test="contains(@S, '8218')">
											<xsl:call-template name="k-8218"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="k-dummy"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</div>
						</xsl:if>
					</td>
				</xsl:if>
				<xsl:if test="lso:StartDateTime">
					<th>Start-dato</th>
					<td width="{((($col)-2-count(lso:Observation/lso:Description)*2)*number(not(lso:EndDateTime | lso:OrgDate))+1)*$std-td}px" colspan="{(($col)-2-count(lso:Observation/lso:Description)*2)*number(not(lso:EndDateTime | lso:OrgDate))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="lso:StartDateTime/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="lso:EndDateTime">
					<th>Slutt-dato</th>
					<td width="{((($col)-2-count(lso:Observation/lso:Description | lso:StartDateTime)*2)*number(not(lso:OrgDate))+1)*$std-td}px" colspan="{(($col)-2-count(lso:Observation/lso:Description | lso:StartDateTime)*2)*number(not(lso:OrgDate))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="lso:EndDateTime/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="lso:OrgDate">
					<th>Opprinnelses-dato</th>
					<td colspan="{($col)-1-count(lso:Observation/lso:Description | lso:StartDateTime | lso:EndDateTime)*2}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="lso:OrgDate/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="lso:Observation/lso:Comment">
			<tr>
				<th>Kommentar</th>
				<td colspan="{($col)-1}">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="lso:Observation/lso:Comment"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
	<xsl:template match="lso:ServProvider">
		<xsl:param name="col"/>
		<tr>
			<th colspan="{$col}" class="h3">Mottaker
				<xsl:if test="lso:HCP/lso:MedSpeciality"> - Spesialitet:&#160;<xsl:for-each select="lso:HCP/lso:MedSpeciality">
						<xsl:choose>
							<xsl:when test="contains(@S, '7426')">
								<xsl:call-template name="k-7426"/>
							</xsl:when>
							<xsl:when test="contains(@S, '8451')">
								<xsl:call-template name="k-8451"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="k-dummy"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:if>
			</th>
		</tr>
		<xsl:for-each select="lso:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="lso:Requester">
		<xsl:param name="col"/>
		<tr>
			<th colspan="{$col}" class="h3">Avsender
				<xsl:if test="lso:HCP/lso:MedSpeciality"> - Spesialitet:&#160;<xsl:for-each select="lso:HCP/lso:MedSpeciality">
						<xsl:choose>
							<xsl:when test="contains(@S, '7426')">
								<xsl:call-template name="k-7426"/>
							</xsl:when>
							<xsl:when test="contains(@S, '8451')">
								<xsl:call-template name="k-8451"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="k-dummy"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:if>
			</th>
		</tr>
		<xsl:for-each select="lso:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="lso:PaymentResponsible">
		<xsl:param name="col"/>
		<tr>
			<th colspan="{$col}" class="h3">Betalingsansvarlig
				<xsl:if test="lso:TypeGuarantor"> - <xsl:value-of select="lso:TypeGuarantor"/>
				</xsl:if>
			</th>
		</tr>
		<xsl:for-each select="lso:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="lso:CopyDest">
		<xsl:param name="col"/>
		<tr>
			<th colspan="{$col}" class="h3">Kopimottaker
				<xsl:if test="lso:CopyDestRole/lso:MsgType"> - kopi&#160;av:&#160;<xsl:for-each select="lso:CopyDestRole/lso:MsgType">
						<xsl:call-template name="k-8236"/>
					</xsl:for-each>
				</xsl:if>
			</th>
		</tr>
		<xsl:for-each select="lso:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="lso:ResponsibleHcp">
		<xsl:param name="col"/>
		<tr>
			<th colspan="{$col}" class="h3">
				<xsl:choose>
					<xsl:when test="lso:Relation">
						<xsl:for-each select="lso:Relation">
							<xsl:call-template name="k-8254"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Ansvarlig&#160;helsetjenesteenhet</xsl:otherwise>
				</xsl:choose>
			</th>
		</tr>
		<xsl:for-each select="lso:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="lso:AdmLocation">
		<xsl:param name="col"/>
		<tr>
			<th colspan="{$col}" class="h3">Oppholdssted for pasient
				<xsl:if test="lso:AdmCat"> - Type&#160;tjeneste:&#160;<xsl:for-each select="lso:AdmCat">
						<xsl:call-template name="k-8240"/>
					</xsl:for-each>
				</xsl:if>
			</th>
		</tr>
		<xsl:for-each select="lso:Location/lso:Inst">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="lso:Location/lso:Inst/lso:Dept">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="lso:Location/lso:Inst/lso:HCPerson">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="lso:Location/lso:Address">
			<xsl:variable name="antall-tel" select="count(lso:TeleAddress)"/>
			<tr>
				<xsl:apply-templates select="lso:TeleAddress">
					<xsl:with-param name="col" select="(($col)-1)*number(not(lso:Type and (lso:PostalCode or lso:City)))+1"/>
				</xsl:apply-templates>
				<xsl:if test="lso:Type and (lso:PostalCode or lso:City)">
					<xsl:apply-templates select=".">
						<xsl:with-param name="col" select="($col)-1-($antall-tel)*2"/>
					</xsl:apply-templates>
				</xsl:if>
			</tr>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="lso:HCP">
		<xsl:param name="col"/>
		<xsl:for-each select="lso:Inst">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="lso:Inst/lso:Dept">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="lso:Inst/lso:HCPerson">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="lso:HCProf">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="lso:Address">
			<xsl:variable name="antall-tel" select="count(lso:TeleAddress)"/>
			<tr>
				<xsl:apply-templates select="lso:TeleAddress">
					<xsl:with-param name="col" select="(($col)-1)*number(not(lso:Type and (lso:PostalCode or lso:City)))+1"/>
				</xsl:apply-templates>
				<xsl:if test="lso:Type and (lso:PostalCode or lso:City)">
					<xsl:apply-templates select=".">
						<xsl:with-param name="col" select="($col)-1-($antall-tel)*2"/>
					</xsl:apply-templates>
				</xsl:if>
			</tr>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="lso:HCProf">
		<xsl:param name="col"/>
		<th>
			<xsl:choose>
				<xsl:when test="lso:Type">
					<xsl:for-each select="lso:Type">
						<xsl:call-template name="k-9060"/>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>Helsepersonell</xsl:otherwise>
			</xsl:choose>
		</th>
		<td width="{$std-td}px">
			<xsl:value-of select="lso:Name"/>
		</td>
		<th>
			<xsl:choose>
				<xsl:when test="lso:TypeId">
					<xsl:for-each select="lso:TypeId">
						<xsl:call-template name="k-8116"/>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>Id</xsl:otherwise>
			</xsl:choose>
		</th>
		<xsl:choose>
			<xsl:when test="lso:AdditionalId">
				<td width="{$std-td}px">
					<xsl:value-of select="lso:Id"/>
				</td>
			</xsl:when>
			<xsl:otherwise>
				<td colspan="{($col)-3}">
					<xsl:value-of select="lso:Id"/>
				</td>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="lso:AdditionalId">
			<xsl:variable name="antall-id" select="count(lso:AdditionalId)"/>
			<xsl:for-each select="lso:AdditionalId">
				<xsl:apply-templates select=".">
					<xsl:with-param name="col">
						<xsl:choose>
							<xsl:when test="position() = $antall-id">
								<xsl:value-of select="($col)-3-($antall-id)*2"/>
							</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	<xsl:template match="lso:Inst">
		<xsl:param name="col"/>
		<th>Navn</th>
		<td width="{$std-td}px">
			<xsl:value-of select="lso:Name"/>
		</td>
		<th>
			<xsl:choose>
				<xsl:when test="lso:TypeId">
					<xsl:for-each select="lso:TypeId">
						<xsl:call-template name="k-9051"/>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>Id</xsl:otherwise>
			</xsl:choose>
		</th>
		<xsl:choose>
			<xsl:when test="lso:AdditionalId">
				<td width="{$std-td}px">
					<xsl:value-of select="lso:Id"/>
				</td>
			</xsl:when>
			<xsl:otherwise>
				<td colspan="{($col)-3}">
					<xsl:value-of select="lso:Id"/>
				</td>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="lso:AdditionalId">
			<xsl:variable name="antall-id" select="count(lso:AdditionalId)"/>
			<xsl:for-each select="lso:AdditionalId">
				<xsl:apply-templates select=".">
					<xsl:with-param name="col">
						<xsl:choose>
							<xsl:when test="position() = $antall-id">
								<xsl:value-of select="($col)-3-($antall-id)*2"/>
							</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	<xsl:template match="lso:Dept">
		<xsl:param name="col"/>
		<th>
			<xsl:choose>
				<xsl:when test="lso:Type">
					<xsl:for-each select="lso:Type">
						<xsl:call-template name="k-8624"/>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>Avdeling</xsl:otherwise>
			</xsl:choose>
		</th>
		<td width="{$std-td}px">
			<xsl:value-of select="lso:Name"/>
		</td>
		<th>
			<xsl:choose>
				<xsl:when test="lso:TypeId">
					<xsl:for-each select="lso:TypeId">
						<xsl:call-template name="k-9051"/>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>Id</xsl:otherwise>
			</xsl:choose>
		</th>
		<xsl:choose>
			<xsl:when test="lso:AdditionalId">
				<td width="{$std-td}px">
					<xsl:value-of select="lso:Id"/>
				</td>
			</xsl:when>
			<xsl:otherwise>
				<td colspan="{($col)-3}">
					<xsl:value-of select="lso:Id"/>
				</td>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="lso:AdditionalId">
			<xsl:variable name="antall-id" select="count(lso:AdditionalId)"/>
			<xsl:for-each select="lso:AdditionalId">
				<xsl:apply-templates select=".">
					<xsl:with-param name="col">
						<xsl:choose>
							<xsl:when test="position() = $antall-id">
								<xsl:value-of select="($col)-3-($antall-id)*2"/>
							</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	<xsl:template match="lso:HCPerson">
		<xsl:param name="col"/>
		<th>Helsepersonell</th>
		<td width="{$std-td}px">
			<xsl:value-of select="lso:Name"/>
		</td>
		<th>
			<xsl:choose>
				<xsl:when test="lso:TypeId">
					<xsl:for-each select="lso:TypeId">
						<xsl:call-template name="k-8116"/>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>Id</xsl:otherwise>
			</xsl:choose>
		</th>
		<xsl:choose>
			<xsl:when test="lso:AdditionalId">
				<td width="{$std-td}px">
					<xsl:value-of select="lso:Id"/>
				</td>
			</xsl:when>
			<xsl:otherwise>
				<td colspan="{($col)-3}">
					<xsl:value-of select="lso:Id"/>
				</td>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="lso:AdditionalId">
			<xsl:variable name="antall-id" select="count(lso:AdditionalId)"/>
			<xsl:for-each select="lso:AdditionalId">
				<xsl:apply-templates select=".">
					<xsl:with-param name="col">
						<xsl:choose>
							<xsl:when test="position() = $antall-id">
								<xsl:value-of select="($col)-3-($antall-id)*2"/>
							</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	<xsl:template match="lso:AdditionalId">
		<xsl:param name="col"/>
		<th>
			<xsl:for-each select="lso:Type">
				<xsl:choose>
					<xsl:when test="local-name(../..)=&quot;Patient&quot; or local-name(../..)=&quot;HCProf&quot; or local-name(../..)=&quot;HCPerson&quot;">
						<xsl:call-template name="k-8116"/>
					</xsl:when>
					<xsl:when test="local-name(..)=&quot;Inst&quot; or local-name(..)=&quot;Dept&quot;">
						<xsl:call-template name="k-9051"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="k-dummy"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</th>
		<td colspan="{$col}">
			<xsl:value-of select="lso:Id"/>
		</td>
	</xsl:template>
	<xsl:template match="lso:Address">
		<xsl:param name="col"/>
		<th>
			<xsl:choose>
				<xsl:when test="lso:Type">
					<xsl:for-each select="lso:Type">
						<xsl:call-template name="k-3401"/>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>Adresse</xsl:otherwise>
			</xsl:choose>
		</th>
		<td colspan="{$col}">
			<xsl:if test="lso:StreetAdr">
				<xsl:value-of select="lso:StreetAdr"/>,&#160;</xsl:if>
			<xsl:if test="lso:PostalCode">
				<xsl:value-of select="lso:PostalCode"/>
			</xsl:if>
			<xsl:if test="lso:City">&#160;<xsl:value-of select="lso:City"/>
			</xsl:if>
			<xsl:if test="lso:CityDistr">,&#160;<xsl:for-each select="lso:CityDistr">
					<xsl:call-template name="k-3403"/>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="lso:County">,&#160;<xsl:for-each select="lso:County">
					<xsl:call-template name="k-3402"/>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="lso:Country">,&#160;<xsl:for-each select="lso:Country">
					<xsl:call-template name="k-9043"/>
				</xsl:for-each>
			</xsl:if>
		</td>
	</xsl:template>
	<xsl:template match="lso:TeleAddress">
		<xsl:param name="col"/>
		<th>
			<xsl:choose>
				<xsl:when test="starts-with(@V, &quot;tel:&quot;) or starts-with(@V, &quot;callto:&quot;)">Telefon</xsl:when>
				<xsl:when test="starts-with(@V, &quot;fax:&quot;)">Faks</xsl:when>
				<xsl:when test="starts-with(@V, &quot;mailto:&quot;)">e-post</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-before(@V, &quot;:&quot;)"/>
				</xsl:otherwise>
			</xsl:choose>
		</th>
		<td colspan="{$col}">
			<xsl:value-of select="substring-after(@V, &quot;:&quot;)"/>
		</td>
	</xsl:template>
	<xsl:template match="lso:RefDoc">
		<xsl:param name="col"/>
		<xsl:if test="lso:MsgType or lso:Id or lso:IssueDate or lso:MimeType or lso:Compression">
			<tr>
				<xsl:if test="lso:MsgType">
					<th>Type</th>
					<td width="{((($col)-2)*number(not(lso:Id | lso:IssueDate | lso:MimeType | lso:Compression))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lso:Id | lso:IssueDate | lso:MimeType | lso:Compression))+1}">
						<xsl:for-each select="lso:MsgType">
							<xsl:call-template name="k-8114"/>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="lso:Id">
					<th>Id</th>
					<td width="{((($col)-2-count(lso:MsgType)*2)*number(not(lso:IssueDate | lso:MimeType | lso:Compression))+1)*$std-td}px" colspan="{(($col)-2-count(lso:MsgType)*2)*number(not(lso:IssueDate | lso:MimeType | lso:Compression))+1}">
						<xsl:value-of select="lso:Id"/>
					</td>
				</xsl:if>
				<xsl:if test="lso:IssueDate">
					<th>Utstedt-dato</th>
					<td width="{((($col)-2-count(lso:MsgType | lso:Id)*2)*number(not(lso:MimeType | lso:Compression))+1)*$std-td}px" colspan="{(($col)-2-count(lso:MsgType | lso:Id)*2)*number(not(lso:MimeType | lso:Compression))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="lso:IssueDate/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="lso:MimeType">
					<th>Mimetype</th>
					<td width="{((($col)-2-count(lso:MsgType | lso:Id | lso:IssueDate)*2)*number(not(lso:Compression))+1)*$std-td}px" colspan="{(($col)-2-count(lso:MsgType | lso:Id | lso:IssueDate)*2)*number(not(lso:Compression))+1}">
						<xsl:value-of select="lso:MimeType"/>
					</td>
				</xsl:if>
				<xsl:if test="lso:Compression">
					<th>Komprimering</th>
					<td colspan="{($col)-1-count(lso:MsgType | lso:Id | lso:IssueDate | lso:MimeType)*2}">
						<xsl:for-each select="lso:Compression">
							<xsl:call-template name="k-1204"/>
						</xsl:for-each>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="lso:Description">
			<tr>
				<th>Beskrivelse</th>
				<td colspan="{($col)-1}">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="lso:Description"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="lso:Content or lso:FileReference">
			<xsl:choose>
				<xsl:when test="contains(lso:MimeType,'image')">
					<tr>
						<th>Bilde</th>
						<xsl:choose>
							<xsl:when test="lso:FileReference">
								<td colspan="{($col)-1}">
									<img>
										<xsl:attribute name="src"><xsl:value-of select="lso:FileReference"/></xsl:attribute>
										<xsl:attribute name="alt">Bilde fra ekstern URL</xsl:attribute>
									</img>
								</td>
							</xsl:when>
							<xsl:when test="lso:Content">
								<td colspan="{($col)-1}">
									<xsl:choose>
										<xsl:when test="lso:Content/base:Base64Container">
											<img>
												<xsl:attribute name="src"><xsl:value-of select="concat('data:',lso:MimeType,';base64,',lso:Content/base:Base64Container)"/></xsl:attribute>
												<xsl:attribute name="alt">Bilde vedlagt som base64-kode</xsl:attribute>
											</img>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="lso:Content"/>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:when>
						</xsl:choose>
					</tr>
				</xsl:when>
				<xsl:when test="contains(lso:MimeType,'pdf')">
					<tr>
						<th>pdf</th>
						<xsl:choose>
							<xsl:when test="lso:FileReference">
								<td colspan="{($col)-1}">
									<object>
										<xsl:attribute name="data"><xsl:value-of select="concat(lso:FileReference,'&#35;view&#61;FitH&#38;toolbar&#61;1')"/></xsl:attribute>
										<xsl:attribute name="type">application/pdf</xsl:attribute>
										<xsl:attribute name="width">100%</xsl:attribute>
										<xsl:attribute name="height">500px</xsl:attribute>
									</object>
								</td>
							</xsl:when>
							<xsl:when test="lso:Content">
								<td colspan="{($col)-1}">
									<xsl:choose>
										<xsl:when test="lso:Content/base:Base64Container">
											<object>
												<xsl:attribute name="data"><xsl:value-of select="concat('data:application/pdf;base64,',lso:Content/base:Base64Container)"/></xsl:attribute>
												<xsl:attribute name="type">application/pdf</xsl:attribute>
												<xsl:attribute name="width">100%</xsl:attribute>
												<xsl:attribute name="height">500px</xsl:attribute>
											</object>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="lso:Content"/>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:when>
						</xsl:choose>
					</tr>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="lso:Content">
							<xsl:value-of select="lso:Content"/>
						</xsl:when>
						<xsl:when test="lso:FileReference">
							<xsl:value-of select="lso:FileReference"/>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
