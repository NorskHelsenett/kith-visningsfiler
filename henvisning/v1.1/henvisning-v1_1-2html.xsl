<?xml version="1.0" encoding="UTF-8"?>
	<!-- Endringslogg
	- 17.10.23: v3.1.4: Tydeliggjøring av Behov for Tolk - Språk
	- 06.06.17: v3.1.3: Adresse i Helsetjenesteenheter: fjernet ledetekst type når adresse mangler.
	- 27.03.17: v3.1.2: Ny stil "Smooth"
	- 13.02.17: v3.1.1: Lagt til mulighet for å angi parameter "visningStil" som parameter på kommando-linjen.
	- 25.10.16: v3.1.0: La til visningsversjonnr
	- 11.03.16: Bugfix - telefon til pasient vises nå i header
	- 01.11.15: Småjusteringer, bl.a. dynamisk cellebredde, visning av vedlegg mm.
	- 04.05.15: Import av felles kodeverksfil
	- 01.04.12: Første versjon
	-->
	<!-- Om
	- Inngår i Hdirs visningsfiler versjon 2.0
	- Laget i XMLSpy v2015 sp2 (http://www.altova.com) av Jan Sigurd Dragsjø (nhn.no)
	-->
<xsl:stylesheet version="1.0"
	xmlns:h="http://www.kith.no/xmlstds/henvisning/2012-02-15"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:po="http://www.kith.no/xmlstds/po/poKomponent/2009-06-30"
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1"
	xmlns:base="http://www.kith.no/xmlstds/base64container"
	exclude-result-prefixes="h xhtml po fk1 base">

	<xsl:import href="../../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../../felleskomponenter/kodeverk.xsl"/>
	<xsl:import href="../../felleskomponenter/visningstil.xsl"/>


	<!-- Variabel for standard antall kolonner i tabellene-->
	<xsl:variable name="std-col" select="8"/>
	<xsl:variable name="std-td" select="100"/>
	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'henvisning1.1 - v3.1.4 '"/>
	<!-- Variabler for beregning av antall kolonner i legemiddel-tabellen -->
	<xsl:variable name="med-stat-col" select="(($std-col)-2)*number(not(//h:Medication/h:UnitDose | //h:Medication/h:QuantitySupplied | //h:Medication/h:DosageText | //h:Medication/h:IntendedDuration | //h:Medication/h:Comment | //h:InfItem[h:Medication]/h:StartDateTime | //h:InfItem[h:Medication]/h:EndDateTime | //h:InfItem[h:Medication]/h:OrgDate))+1"/>
	<xsl:variable name="med-unit-col" select="(($std-col)-3)*number(not(//h:Medication/h:DosageText | //h:Medication/h:IntendedDuration | //h:Medication/h:Comment | //h:InfItem[h:Medication]/h:StartDateTime | //h:InfItem[h:Medication]/h:EndDateTime | //h:InfItem[h:Medication]/h:OrgDate))+1"/>
	<xsl:variable name="med-text-col" select="(($std-col)-3-number(boolean(//h:Medication/h:UnitDose | //h:Medication/h:QuantitySupplied)))*number(not(//h:Medication/h:Comment | //h:InfItem[h:Medication]/h:StartDateTime | //h:InfItem[h:Medication]/h:EndDateTime | //h:InfItem[h:Medication]/h:OrgDate))+1"/>
	<xsl:variable name="med-com-col" select="(($std-col)-3-number(boolean(//h:Medication/h:UnitDose | //h:Medication/h:QuantitySupplied | //h:Medication/h:DosageText | //h:Medication/h:IntendedDuration)))*number(not(//h:InfItem[h:Medication]/h:StartDateTime | //h:InfItem[h:Medication]/h:EndDateTime | //h:InfItem[h:Medication]/h:OrgDate))+1"/>
	<xsl:variable name="med-sdate-col" select="(($std-col)-3-number(boolean(//h:Medication/h:UnitDose | //h:Medication/h:QuantitySupplied))-number(boolean(//h:Medication/h:DosageText | //h:Medication/h:IntendedDuration))-number(boolean(//h:Medication/h:Comment)))*number(not(//h:InfItem[h:Medication]/h:EndDateTime | //h:InfItem[h:Medication]/h:OrgDate))+1"/>
	<xsl:variable name="med-edate-col" select="(($std-col)-3-number(boolean(//h:Medication/h:UnitDose | //h:Medication/h:QuantitySupplied))-number(boolean(//h:Medication/h:DosageText | //h:Medication/h:IntendedDuration))-number(boolean(//h:Medication/h:Comment))-number(boolean(//h:InfItem[h:Medication]/h:StartDateTime)))*number(not(//h:InfItem[h:Medication]/h:OrgDate))+1"/>
	<xsl:variable name="med-odate-col" select="(($std-col)-2-number(boolean(//h:Medication/h:UnitDose | //h:Medication/h:QuantitySupplied))-number(boolean(//h:Medication/h:DosageText | //h:Medication/h:IntendedDuration))-number(boolean(//h:Medication/h:Comment))-number(boolean(//h:InfItem[h:Medication]/h:StartDateTime))-number(boolean(//h:InfItem[h:Medication]/h:EndDateTime)))"/>
	<!-- Variabler for beregning av antall kolonner i resultat-tabellen -->
	<xsl:variable name="res-res-col" select="(($std-col)-2)*number(not(//h:ResultItem/h:InvDate | //h:InfItem[h:ResultItem]/h:StartDateTime | //h:InfItem[h:ResultItem]/h:EndDateTime | //h:InfItem[h:ResultItem]/h:OrgDate))+1"/>
	<xsl:variable name="res-idate-col" select="(($std-col)-3)*number(not(//h:InfItem[h:ResultItem]/h:StartDateTime | //h:InfItem[h:ResultItem]/h:EndDateTime | //h:InfItem[h:ResultItem]/h:OrgDate))+1"/>
	<xsl:variable name="res-sdate-col" select="(($std-col)-3-number(boolean(//h:ResultItem/h:InvDate)))*number(not(//h:InfItem[h:ResultItem]/h:EndDateTime | //h:InfItem[h:ResultItem]/h:OrgDate))+1"/>
	<xsl:variable name="res-edate-col" select="(($std-col)-3-number(boolean(//h:ResultItem/h:InvDate))-number(boolean(//h:InfItem[h:ResultItem]/h:StartDateTime)))*number(not(//h:InfItem[h:ResultItem]/h:OrgDate))+1"/>
	<xsl:variable name="res-odate-col" select="(($std-col)-2-number(boolean(//h:ResultItem/h:InvDate))-number(boolean(//h:InfItem[h:ResultItem]/h:StartDateTime))-number(boolean(//h:InfItem[h:ResultItem]/h:EndDateTime)))"/>
	<xsl:template match="/">
		<html>
			<head>
				<title>Henvisning</title>
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
	<xsl:template match="h:Message">
		<xsl:for-each select="h:ServReq">
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
						<xsl:apply-templates select="h:Requester" mode="hode"/>
					</div>
				</div>
				<xsl:choose>
					<xsl:when test="h:Patient">
						<div class="No-line-headerContent">
							<div class="No-line-caption">Pasient&#160;</div>
							<div class="No-line-content">
								<xsl:apply-templates select="h:Patient" mode="hode"/>
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
						<xsl:apply-templates select="h:ServProvider" mode="hode"/>
					</div>
				</div>
				<xsl:choose>
					<xsl:when test="h:CopyDest">
						<div class="No-line-headerContent">
							<div class="No-line-caption">Kopimottaker(e)&#160;</div>
							<div class="No-line-content">
								<xsl:apply-templates select="h:CopyDest" mode="hode"/>
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
	<xsl:template match="h:Requester" mode="hode">
		<xsl:apply-templates select="h:HCP" mode="hode"/>
	</xsl:template>
	<xsl:template match="h:ServProvider" mode="hode">
		<xsl:apply-templates select="h:HCP" mode="hode"/>
	</xsl:template>
	<xsl:template match="h:Patient" mode="hode">
		<div>
			<xsl:value-of select="h:Name"/>&#160;
			<span class="strong">
				<xsl:value-of select="h:TypeOffId/@V"/>:&#160;</span>
			<xsl:value-of select="substring(h:OffId, 1,6)"/>&#160;<xsl:value-of select="substring(h:OffId, 7)"/>&#160;
		</div>
		<xsl:if test="h:DateOfDeath">
			<div>
				<span class="strong">Dødsdato:&#160;</span>
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="h:DateOfDeath/@V"/>
				</xsl:call-template>
			&#160;</div>
		</xsl:if>
		<xsl:apply-templates select="h:Address" mode="hode"/>
	</xsl:template>
	<xsl:template match="h:HCPerson" mode="hode">
		<div>
			<xsl:value-of select="h:Name"/>&#160;</div>
		<xsl:apply-templates select="h:Address" mode="hode"/>
	</xsl:template>
	<xsl:template match="h:HCP" mode="hode">
		<xsl:apply-templates select="h:Inst" mode="hode"/>
		<xsl:apply-templates select="h:HCProf" mode="hode"/>
		<xsl:apply-templates select="h:Address" mode="hode"/>
	</xsl:template>
	<xsl:template match="h:Inst" mode="hode">
		<xsl:apply-templates select="h:HCPerson" mode="hode"/>
		<div>
			<div class="NoPrint">
				<span class="strong">Institusjon:&#160;</span>
			</div>
			<xsl:value-of select="h:Name"/>
		</div>
		<xsl:for-each select="h:Dept">
			<div>
				<div class="NoPrint">-&#160;</div>
				<xsl:value-of select="h:Name"/>&#160;</div>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="h:HCProf" mode="hode">
		<div>
			<xsl:for-each select="h:Type">
				<xsl:call-template name="k-9060"/>&#160;</xsl:for-each>
			<xsl:value-of select="h:Name"/>
		</div>
	</xsl:template>
	<xsl:template match="h:CopyDest" mode="hode">
		<xsl:apply-templates select="h:HCP" mode="hode"/>
	</xsl:template>
	<xsl:template match="h:Address" mode="hode">
		<xsl:if test="h:Type and (h:StreetAdr or h:PostalCode or h:City or h:CityDistr)">
			<div class="NoPrint">&#160;<b>
					<xsl:for-each select="h:Type">
						<xsl:call-template name="k-3401"/>&#160;</xsl:for-each>
				</b>
			</div>
		</xsl:if>
		<xsl:if test="h:StreetAdr">
			<div>
				<xsl:value-of select="h:StreetAdr"/>
			</div>
		</xsl:if>
		<xsl:if test="h:PostalCode or h:City">
			<xsl:if test="h:StreetAdr">
				<div class="NoPrint">,</div>
			</xsl:if>
			<div>
				<xsl:value-of select="h:PostalCode"/>&#160;<xsl:value-of select="h:City"/>
			</div>
		</xsl:if>
		<xsl:for-each select="h:CityDistr">
			<div class="NoPrint">,</div>
			<div>
				<xsl:call-template name="k-3403"/>
			</div>
		</xsl:for-each>
		<xsl:for-each select="h:County">
			<div class="NoPrint">,</div>
			<div>
				<xsl:call-template name="k-3402"/>
			</div>
		</xsl:for-each>
		<xsl:for-each select="h:Country">
			<div class="NoPrint">,</div>
			<div>
				<xsl:call-template name="k-9043"/>
			</div>
		</xsl:for-each>
		<xsl:for-each select="h:TeleAddress">
			<div class="NoPrint">&#160;</div>
			<xsl:apply-templates select="." mode="hode"/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="h:TeleAddress" name="h:TeleAddress" mode="hode">
		<xsl:if test="starts-with(@V, &quot;tel:&quot;) or starts-with(@V, &quot;callto:&quot;)">
			<div>
				<span class="strong">Telefon:</span>&#160;<xsl:value-of select="substring-after(@V, &quot;:&quot;)"/>&#160;</div>
		</xsl:if>
		<xsl:if test="starts-with(@V, &quot;fax:&quot;)">
			<div>
				<span class="strong">Faks:</span>&#160;<xsl:value-of select="substring-after(@V, &quot;:&quot;)"/>&#160;</div>
		</xsl:if>
		<xsl:if test="starts-with(@V, &quot;mailto:&quot;)">
			<div>
				<span class="strong">e-post:</span>&#160;<xsl:value-of select="substring-after(@V, &quot;:&quot;)"/>&#160;</div>
		</xsl:if>
	</xsl:template>
	<!-- Hoveddokumentet -->
	<xsl:template name="ResultBody">
		<xsl:variable name="position" select="position()"/>
		<xsl:variable name="color">
			<xsl:choose>
				<xsl:when test="h:ServType[@V='M' or @V='C' or @V='O']">red</xsl:when>
				<xsl:otherwise>black</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="color2">
			<xsl:choose>
				<xsl:when test="h:ReqServ/h:ServType[@V='M' or @V='C' or @V='O']">red</xsl:when>
				<xsl:otherwise>black</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div class="{$stil}">
			<xsl:call-template name="FellesMeny">
				<xsl:with-param name="position" select="position()"/>
			</xsl:call-template>
			<!-- Overskrift og tabell for henvisningen -->
			<h1>Henvisning&#160;-&#160;<xsl:for-each select="h:MsgDescr">
					<xsl:call-template name="k-8455"/>
				</xsl:for-each>
				<xsl:for-each select="h:ServType[@V!='N']">&#160;-
					<font color="{$color}">
						<xsl:call-template name="k-7309"/>
					</font>
				</xsl:for-each>
				<xsl:for-each select="h:ReqServ/h:ServType[@V!='N']">
					&#160;Status&#160;rekvirert&#160;tjeneste:&#160;-
					<font color="{$color2}">
						<xsl:call-template name="k-7309"/>
					</font>
				</xsl:for-each>
			</h1>
			<table>
				<tbody>
					<xsl:apply-templates select="."/>
				</tbody>
			</table>
			<!-- Overskrift og tabell for Diagnoser -->
			<xsl:if test="h:Diagnosis or h:ReasonAsText[h:Heading/@V='DIAG'] or //h:InfItem[h:Type/@V='H' or h:Type/@V='B']">
				<xsl:variable name="id10">
					<xsl:value-of select="concat('Diagnosis',$position)"/>
				</xsl:variable>
				<h2 id="{$id10}">Diagnoser</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="h:Diagnosis"/>
						<xsl:apply-templates select="h:ReasonAsText[h:Heading/@V='DIAG']"/>
						<xsl:for-each select="//h:InfItem[h:Type/@V='H' or h:Type/@V='B']">
							<xsl:apply-templates/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for CAVE og NB-opplysninger -->
			<xsl:if test="//h:InfItem[h:Type/@V='CAVE' or h:Type/@V='NB']">
				<xsl:variable name="id20">
					<xsl:value-of select="concat('CAVE',$position)"/>
				</xsl:variable>
				<h2 id="{$id20}">
					<xsl:if test="//h:InfItem[h:Type/@V='CAVE']">CAVE</xsl:if>
					<xsl:if test="//h:InfItem[h:Type/@V='CAVE'] and //h:InfItem[h:Type/@V='NB']">&#160;og&#160;</xsl:if>
					<xsl:if test="//h:InfItem[h:Type/@V='NB']">NB-opplysninger</xsl:if>
				</h2>
				<table>
					<tbody>
						<xsl:for-each select="//h:InfItem[h:Type/@V='CAVE' or h:Type/@V='NB']">
							<xsl:apply-templates/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Problemstilling -->
			<xsl:if test="//h:ReasonAsText[h:Heading/@V='PROB'] or //h:InfItem[h:Type/@V='SYMP' or h:Type/@V='PROG' or h:Type/@V='SM']">
				<xsl:variable name="id30">
					<xsl:value-of select="concat('PROB',$position)"/>
				</xsl:variable>
				<h2 id="{$id30}">Problemstilling</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="h:ReasonAsText[h:Heading/@V='PROB']"/>
						<xsl:for-each select="//h:InfItem[h:Type/@V='SYMP' or h:Type/@V='PROG' or h:Type/@V='SM']">
							<xsl:apply-templates/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Forventet utredning/behandling -->
			<xsl:if test="h:ReasonAsText[h:Heading/@V='UTRED']">
				<xsl:variable name="id40">
					<xsl:value-of select="concat('UTRED',$position)"/>
				</xsl:variable>
				<h2 id="{$id40}">Forventet utredning/behandling</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="h:ReasonAsText[h:Heading/@V='UTRED']"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Kliniske opplysninger -->
			<xsl:if test="//h:InfItem[h:Type/@V='OPPL']">
				<xsl:variable name="id50">
					<xsl:value-of select="concat('OPPL',$position)"/>
				</xsl:variable>
				<h2 id="{$id50}">Kliniske opplysninger</h2>
				<table>
					<tbody>
						<xsl:for-each select="//h:InfItem[h:Type/@V='OPPL']">
							<xsl:apply-templates/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Gynekologiske opplysninger -->
			<xsl:if test="//h:InfItem[h:Type/@V='GOPL' or h:Type/@V='GBEH']">
				<xsl:variable name="id60">
					<xsl:value-of select="concat('GOPL',$position)"/>
				</xsl:variable>
				<h2 id="{$id60}">Gynekologiske opplysninger</h2>
				<table>
					<tbody>
						<xsl:for-each select="//h:InfItem[h:Type/@V='GOPL' or h:Type/@V='GBEH']">
							<xsl:apply-templates/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Spesialistvurdering -->
			<xsl:if test="h:ReasonAsText[h:Heading/@V='SVU']">
				<xsl:variable name="id70">
					<xsl:value-of select="concat('SVU',$position)"/>
				</xsl:variable>
				<h2 id="{$id70}">Spesialistvurdering</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="h:ReasonAsText[h:Heading/@V='SVU']"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Vurdering -->
			<xsl:if test="h:ReasonAsText[h:Heading/@V='VU']">
				<xsl:variable name="id80">
					<xsl:value-of select="concat('VU',$position)"/>
				</xsl:variable>
				<h2 id="{$id80}">Vurdering</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="h:ReasonAsText[h:Heading/@V='VU']"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Annen begrunnelse for henvisningen -->
			<xsl:if test="h:ReasonAsText[h:Heading/@V='BG' or h:Heading/@V='BUP-BM' or h:Heading/@V='BUP-HG' or h:Heading/@V='KF' or h:Heading/@V='MAAL' or h:Heading/@V='MU' or h:Heading/@V='RU' or h:Heading/@V='UP' or not(h:Heading)]">
				<xsl:variable name="id90">
					<xsl:value-of select="concat('Annen',$position)"/>
				</xsl:variable>
				<h2 id="{$id90}">Annen begrunnelse for henvisningen</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="h:ReasonAsText[h:Heading/@V='BG' or h:Heading/@V='BUP-BM' or h:Heading/@V='BUP-HG' or h:Heading/@V='KF' or h:Heading/@V='MAAL' or h:Heading/@V='MU' or h:Heading/@V='RU' or h:Heading/@V='UP' or not(h:Heading)]"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Sykehistorie -->
			<xsl:if test="//h:InfItem[h:Type/@V='ANAM' or h:Type/@V='TB' or h:Type/@V='US']">
				<xsl:variable name="id100">
					<xsl:value-of select="concat('ANAM',$position)"/>
				</xsl:variable>
				<h2 id="{$id100}">Sykehistorie</h2>
				<table>
					<tbody>
						<xsl:for-each select="//h:InfItem[h:Type/@V='ANAM' or h:Type/@V='TB' or h:Type/@V='US']">
							<xsl:apply-templates/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Funn/undersøkelsesresultat -->
			<xsl:if test="//h:InfItem[h:Type/@V='FUNN'] or h:ReasonAsText[h:Heading/@V='FU']">
				<xsl:variable name="id110">
					<xsl:value-of select="concat('ResultItem',$position)"/>
				</xsl:variable>
				<h2 id="{$id110}">Funn/undersøkelsesresultat</h2>
				<table>
					<tbody>
						<xsl:for-each select="//h:InfItem[h:Type/@V='FUNN']/h:Observation">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
						<xsl:for-each select="//h:ResultItem">
							<xsl:if test="position()=1">
								<tr>
									<th>Undersøkelse</th>
									<th colspan="{$res-res-col}">Funn/resultat</th>
									<xsl:if test="//h:ResultItem/h:InvDate">
										<th colspan="{$res-idate-col}">Tidspunkt&#160;for&#160;undersøkelsen</th>
									</xsl:if>
									<xsl:if test="//h:InfItem[h:ResultItem]/h:StartDateTime">
										<th colspan="{$res-sdate-col}">Starttidspunkt</th>
									</xsl:if>
									<xsl:if test="//h:InfItem[h:ResultItem]/h:EndDateTime">
										<th colspan="{$res-edate-col}">Sluttidspunkt</th>
									</xsl:if>
									<xsl:if test="//h:InfItem[h:ResultItem]/h:OrgDate">
										<th colspan="{$res-odate-col}">Tidspunkt&#160;for&#160;opprinnelse</th>
									</xsl:if>
								</tr>
							</xsl:if>
							<tr>
								<xsl:apply-templates select="."/>
							</tr>
						</xsl:for-each>
						<xsl:apply-templates select="h:ReasonAsText[h:Heading/@V='FU']"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Prosedyrer -->
			<xsl:if test="//h:InfItem[h:Type/@V='OPIN' or h:Type/@V='MPRS' or h:Type/@V='PRS']">
				<xsl:variable name="id120">
					<xsl:value-of select="concat('OPIN',$position)"/>
				</xsl:variable>
				<h2 id="{$id120}">Prosedyrer</h2>
				<table>
					<tbody>
						<xsl:for-each select="//h:InfItem[h:Type/@V='OPIN' or h:Type/@V='MPRS' or h:Type/@V='PRS']">
							<xsl:apply-templates/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Forløp og behandling -->
			<xsl:if test="h:ReasonAsText[h:Heading/@V='FO']">
				<xsl:variable name="id130">
					<xsl:value-of select="concat('FO',$position)"/>
				</xsl:variable>
				<h2 id="{$id130}">Forløp og behandling</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="h:ReasonAsText[h:Heading/@V='FO']"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Funksjonsnivå/hjelpetiltak -->
			<xsl:if test="h:ReasonAsText[h:Heading/@V='HJ']">
				<xsl:variable name="id140">
					<xsl:value-of select="concat('HJ',$position)"/>
				</xsl:variable>
				<h2 id="{$id140}">Funksjonsnivå/hjelpetiltak</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="h:ReasonAsText[h:Heading/@V='HJ']"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Medisinering -->
			<xsl:if test="//h:InfItem[h:Type/@V='MEDB']">
				<xsl:variable name="id150">
					<xsl:value-of select="concat('Medication',$position)"/>
				</xsl:variable>
				<h2 id="{$id150}">Medisinering</h2>
				<table>
					<tbody>
						<xsl:for-each select="//h:InfItem[h:Type/@V='MEDB']/h:Observation | //h:InfItem[h:Type/@V='MEDB']/h:ResultItem">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
						<xsl:for-each select="//h:Medication">
							<xsl:if test="position()=1">
								<tr>
									<th>Legemiddel</th>
									<th colspan="{$med-stat-col}">Status</th>
									<xsl:if test="//h:Medication/h:UnitDose or //h:Medication/h:QuantitySupplied">
										<th colspan="{$med-unit-col}">Mengde</th>
									</xsl:if>
									<xsl:if test="//h:Medication/h:DosageText or //h:Medication/h:IntendedDuration">
										<th colspan="{$med-text-col}">
											<xsl:if test="//h:Medication/h:DosageText">Dosering</xsl:if>
											<xsl:if test="//h:Medication/h:DosageText and //h:Medication/h:IntendedDuration">/</xsl:if>
											<xsl:if test="//h:Medication/h:IntendedDuration">Varighet</xsl:if>
										</th>
									</xsl:if>
									<xsl:if test="//h:Medication/h:Comment">
										<th colspan="{$med-com-col}">Kommentar</th>
									</xsl:if>
									<xsl:if test="//h:InfItem[h:Medication]/h:StartDateTime">
										<th colspan="{$med-sdate-col}">Starttidspunkt</th>
									</xsl:if>
									<xsl:if test="//h:InfItem[h:Medication]/h:EndDateTime">
										<th colspan="{$med-edate-col}">Sluttidspunkt</th>
									</xsl:if>
									<xsl:if test="//h:InfItem[h:Medication]/h:OrgDate">
										<th colspan="{$med-odate-col}">Tidspunkt&#160;for&#160;opprinnelse</th>
									</xsl:if>
								</tr>
							</xsl:if>
							<tr>
								<xsl:apply-templates select="."/>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Familie/sosialt -->
			<xsl:if test="h:ReasonAsText[h:Heading/@V='FA']">
				<xsl:variable name="id160">
					<xsl:value-of select="concat('FA',$position)"/>
				</xsl:variable>
				<h2 id="{$id160}">Familie/sosialt</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="h:ReasonAsText[h:Heading/@V='FA']"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Informasjon til pasient/pårørende -->
			<xsl:if test="h:ReasonAsText[h:Heading/@V='IP']">
				<xsl:variable name="id170">
					<xsl:value-of select="concat('IP',$position)"/>
				</xsl:variable>
				<h2 id="{$id170}">Informasjon til pasient/pårørende</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="h:ReasonAsText[h:Heading/@V='IP']"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Sykemelding -->
			<xsl:if test="//h:InfItem[h:Type/@V='SYKM']">
				<xsl:variable name="id180">
					<xsl:value-of select="concat('SYKM',$position)"/>
				</xsl:variable>
				<h2 id="{$id180}">Sykemelding</h2>
				<table>
					<tbody>
						<xsl:for-each select="//h:InfItem[h:Type/@V='SYKM']">
							<xsl:apply-templates/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Kommentarer -->
			<xsl:if test="h:Comment">
				<xsl:variable name="id190">
					<xsl:value-of select="concat('Comment',$position)"/>
				</xsl:variable>
				<h2 id="{$id190}">Kommentarer</h2>
				<table>
					<tbody>
						<xsl:for-each select="h:Comment">
							<tr>
								<th>
									<xsl:choose>
										<xsl:when test="h:Heading">
											<xsl:for-each select="h:Heading">
												<xsl:call-template name="k-8234"/>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>Kommentar</xsl:otherwise>
									</xsl:choose>
								</th>
								<td colspan="{($std-col)-1}">
									<xsl:if test="h:TextResultValue">
										<div>
											<xsl:value-of select="h:TextResultValue"/>
										</div>
									</xsl:if>
									<xsl:for-each select="h:CodedComment">
										<div>
											<xsl:choose>
												<xsl:when test="contains(@S,'8403')">
													<xsl:call-template name="k-8403"/>
												</xsl:when>
												<xsl:when test="contains(@S,'8419')">
													<xsl:call-template name="k-8419"/>
												</xsl:when>
												<xsl:when test="contains(@S,'9513')">
													<xsl:call-template name="k-9513"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:call-template name="k-dummy"/>
												</xsl:otherwise>
											</xsl:choose>
										</div>
									</xsl:for-each>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Pasient -->
			<xsl:for-each select="h:Patient">
				<xsl:if test="h:BasisForHealthServices or h:Sex or h:DateOfBirth or h:PatientPrecaution or po:AssistertKommunikasjon or po:ParorendeForesatt or h:ContactPerson or h:PatRelInst or h:Consent or h:AdditionalId">
					<xsl:variable name="id200">
						<xsl:value-of select="concat('Patient',$position)"/>
					</xsl:variable>
					<h2 id="{$id200}">Pasient</h2>
					<table>
						<tbody>
							<xsl:apply-templates select="." mode="full"/>
						</tbody>
					</table>
				</xsl:if>
			</xsl:for-each>
			<!-- Overskrift og tabell for Helsetjenesteenheter -->
			<xsl:if test="h:Patient/h:PatRelHCP">
				<xsl:variable name="id210">
					<xsl:value-of select="concat('PatRelHCP',$position)"/>
				</xsl:variable>
				<h2 id="{$id210}">Helsetjenesteenheter</h2>
				<table>
					<tbody>
						<tr>
							<xsl:if test="//h:PatRelHCP/h:Relation">
								<th>Pasientrelasjon</th>
							</xsl:if>
							<xsl:if test="//h:PatRelHCP//h:HCProf | //h:PatRelHCP//h:HCPerson | //h:PatRelHCP//h:Dept">
								<th colspan="{(($std-col)-2)*number(not(//h:PatRelHCP//h:HCProf/h:Id | //h:PatRelHCP//h:HCProf/h:AdditionalId | //h:PatRelHCP//h:HCPerson/h:Id | //h:PatRelHCP//h:HCPerson/h:AdditionalId | //h:PatRelHCP//h:Dept/h:Id | //h:PatRelHCP//h:Dept/h:AdditionalId | //h:PatRelHCP//h:Inst/h:Name | //h:PatRelHCP//h:MedSpeciality | //h:PatRelHCP//h:Inst/h:Id | //h:PatRelHCP/h:StartDateTime | //h:PatRelHCP/h:EndDateTime | //h:PatRelHCP//h:Address))+1}">
									<xsl:choose>
										<xsl:when test="//h:PatRelHCP//h:Dept and (//h:PatRelHCP//h:HCProf or //h:PatRelHCP//h:HCPerson)">Person/avd.</xsl:when>
										<xsl:when test="not(//h:PatRelHCP//h:Dept)">Person</xsl:when>
										<xsl:otherwise>Avdeling</xsl:otherwise>
									</xsl:choose>
								</th>
							</xsl:if>
							<xsl:if test="//h:PatRelHCP//h:HCProf/h:Id | //h:PatRelHCP//h:HCProf/h:AdditionalId | //h:PatRelHCP//h:HCPerson/h:Id | //h:PatRelHCP//h:HCPerson/h:AdditionalId | //h:PatRelHCP//h:Dept/h:Id | //h:PatRelHCP//h:Dept/h:AdditionalId">
								<th colspan="{(($std-col)-3)*number(not(//h:PatRelHCP//h:Inst/h:Name | //h:PatRelHCP//h:MedSpeciality | //h:PatRelHCP//h:Inst/h:Id | //h:PatRelHCP/h:StartDateTime | //h:PatRelHCP/h:EndDateTime | //h:PatRelHCP//h:Address))+1}">Id</th>
							</xsl:if>
							<xsl:if test="//h:PatRelHCP//h:Inst/h:Name">
								<th colspan="{(($std-col)-2-number(boolean(//h:PatRelHCP//h:HCProf | //h:PatRelHCP//h:HCPerson | //h:PatRelHCP//h:Dept))-1)*number(not(//h:PatRelHCP//h:MedSpeciality | //h:PatRelHCP//h:Inst/h:Id | //h:PatRelHCP/h:StartDateTime | //h:PatRelHCP/h:EndDateTime | //h:PatRelHCP//h:Address))+1}">Institusjon</th>
							</xsl:if>
							<xsl:if test="//h:PatRelHCP//h:MedSpeciality">
								<th colspan="{(($std-col)-2-number(boolean(//h:PatRelHCP//h:HCProf | //h:PatRelHCP//h:HCPerson | //h:PatRelHCP//h:Dept))-1-number(boolean(//h:PatRelHCP//h:Inst/h:Name)))*number(not(//h:PatRelHCP//h:Inst/h:Id | //h:PatRelHCP/h:StartDateTime | //h:PatRelHCP/h:EndDateTime | //h:PatRelHCP//h:Address))+1}">Medisinsk&#160;spesialitet</th>
							</xsl:if>
							<xsl:if test="//h:PatRelHCP//h:Inst/h:Id">
								<th colspan="{(($std-col)-2-number(boolean(//h:PatRelHCP//h:HCProf | //h:PatRelHCP//h:HCPerson | //h:PatRelHCP//h:Dept))-1-number(boolean(//h:PatRelHCP//h:Inst/h:Name))-number(boolean(//h:PatRelHCP//h:MedSpeciality)))*number(not(//h:PatRelHCP/h:StartDateTime | //h:PatRelHCP/h:EndDateTime | //h:PatRelHCP//h:Address))+1}">Institusjon-id</th>
							</xsl:if>
							<xsl:if test="//h:PatRelHCP/h:StartDateTime | //h:PatRelHCP/h:EndDateTime">
								<th colspan="{(($std-col)-2-number(boolean(//h:PatRelHCP//h:HCProf | //h:PatRelHCP//h:HCPerson | //h:PatRelHCP//h:Dept))-1-number(boolean(//h:PatRelHCP//h:Inst/h:Name))-number(boolean(//h:PatRelHCP//h:MedSpeciality))-number(boolean(//h:PatRelHCP//h:Inst/h:Id)))*number(not(//h:PatRelHCP//h:Address))+1}">Tidsrom</th>
							</xsl:if>
							<xsl:if test="//h:PatRelHCP//h:Address">
								<th colspan="{(($std-col)-1-number(boolean(//h:PatRelHCP//h:HCProf | //h:PatRelHCP//h:HCPerson | //h:PatRelHCP//h:Dept))-1-number(boolean(//h:PatRelHCP//h:Inst/h:Name))-number(boolean(//h:PatRelHCP//h:MedSpeciality))-number(boolean(//h:PatRelHCP//h:Inst/h:Id))-number(boolean(//h:PatRelHCP/h:StartDateTime | //h:PatRelHCP/h:EndDateTime)))}">Kontaktinformasjon</th>
							</xsl:if>
						</tr>
						<xsl:apply-templates select="h:Patient/h:PatRelHCP"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for vedlegg -->
			<xsl:if test="h:RefDoc">
				<xsl:variable name="id220">
					<xsl:value-of select="concat('RefDoc',$position)"/>
				</xsl:variable>
				<h2 id="{$id220}">Vedlegg</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="h:RefDoc"/>
					</tbody>
				</table>
			</xsl:if>
		</div>
	</xsl:template>
	<!-- Meldingshodet - Dokumentopplysninger -->
	<xsl:template name="Footer">
		<div class="{$stil}">
			<h2>Dokumentinformasjon</h2>
			<table>
				<tbody>
					<tr>
						<th>Melding&#160;opprettet</th>
						<td width="{$std-td}">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../h:GenDate/@V"/>
							</xsl:call-template>
						</td>
						<th>Meldingsid</th>
						<td>
							<xsl:value-of select="../h:MsgId"/>
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
		<div class="NoPrint">
			<div id="FellesMeny" class="FellesMeny">
				<ul>
					<xsl:if test="//h:Diagnosis or //h:ReasonAsText[h:Heading/@V='DIAG'] or //h:InfItem[h:Type/@V='H' or h:Type/@V='B']">
						<li>
							<xsl:variable name="temp10" select="concat('Diagnosis',$position)"/>
							<a href="#{$temp10}">Diagnoser</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:InfItem[h:Type/@V='CAVE' or h:Type/@V='NB']">
						<li>
							<xsl:variable name="temp20" select="concat('CAVE',$position)"/>
							<a href="#{$temp20}">
								<xsl:if test="//h:InfItem[h:Type/@V='CAVE']">CAVE</xsl:if>
								<xsl:if test="//h:InfItem[h:Type/@V='CAVE' and h:Type/@V='NB']">&#160;og&#160;</xsl:if>
								<xsl:if test="//h:InfItem[h:Type/@V='NB']">NB-opplysninger</xsl:if>
							</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:ReasonAsText[h:Heading/@V='PROB'] or //h:InfItem[h:Type/@V='SYMP' or h:Type/@V='PROG' or h:Type/@V='SM']">
						<li>
							<xsl:variable name="temp30" select="concat('PROB',$position)"/>
							<a href="#{$temp30}">Problemstilling</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:ReasonAsText[h:Heading/@V='UTRED']">
						<li>
							<xsl:variable name="temp40" select="concat('UTRED',$position)"/>
							<a href="#{$temp40}">Forventet utredning/behandling</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:InfItem[h:Type/@V='OPPL']">
						<li>
							<xsl:variable name="temp50" select="concat('OPPL',$position)"/>
							<a href="#{$temp50}">Kliniske opplysninger</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:InfItem[h:Type/@V='GOPL' or h:Type/@V='GBEH']">
						<li>
							<xsl:variable name="temp60" select="concat('GOPL',$position)"/>
							<a href="#{$temp60}">Gynekologiske opplysninger</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:ReasonAsText[h:Heading/@V='SVU']">
						<li>
							<xsl:variable name="temp70" select="concat('SVU',$position)"/>
							<a href="#{$temp70}">Spesialistvurdering</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:ReasonAsText[h:Heading/@V='VU']">
						<li>
							<xsl:variable name="temp80" select="concat('VU',$position)"/>
							<a href="#{$temp80}">Vurdering</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:ReasonAsText[h:Heading/@V='BG' or h:Heading/@V='BUP-BM' or h:Heading/@V='BUP-HG' or h:Heading/@V='KF' or h:Heading/@V='MAAL' or h:Heading/@V='MU' or h:Heading/@V='RU' or h:Heading/@V='UP' or not(h:Heading)]">
						<li>
							<xsl:variable name="temp90" select="concat('Annen',$position)"/>
							<a href="#{$temp90}">Annen begrunnelse</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:InfItem[h:Type/@V='ANAM' or h:Type/@V='TB' or h:Type/@V='US']">
						<li>
							<xsl:variable name="temp100" select="concat('ANAM',$position)"/>
							<a href="#{$temp100}">Sykehistorie</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:InfItem[h:Type/@V='FUNN'] or //h:ReasonAsText[h:Heading/@V='FU']">
						<li>
							<xsl:variable name="temp110" select="concat('ResultItem',$position)"/>
							<a href="#{$temp110}">Funn/undersøkelsesresultat</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:InfItem[h:Type/@V='OPIN' or h:Type/@V='MPRS' or h:Type/@V='PRS']">
						<li>
							<xsl:variable name="temp120" select="concat('OPIN',$position)"/>
							<a href="#{$temp120}">Prosedyrer</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:ReasonAsText[h:Heading/@V='FO']">
						<li>
							<xsl:variable name="temp130" select="concat('FO',$position)"/>
							<a href="#{$temp130}">Forløp og behandling</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:ReasonAsText[h:Heading/@V='HJ']">
						<li>
							<xsl:variable name="temp140" select="concat('HJ',$position)"/>
							<a href="#{$temp140}">Funksjonsnivå/hjelpetiltak</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:InfItem[h:Type/@V='MEDB']">
						<li>
							<xsl:variable name="temp150" select="concat('Medication',$position)"/>
							<a href="#{$temp150}">Medisinering</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:ReasonAsText[h:Heading/@V='FA']">
						<li>
							<xsl:variable name="temp160" select="concat('FA',$position)"/>
							<a href="#{$temp160}">Familie/sosialt</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:ReasonAsText[h:Heading/@V='IP']">
						<li>
							<xsl:variable name="temp170" select="concat('IP',$position)"/>
							<a href="#{$temp170}">Informasjon til pasient/pårørende</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:InfItem[h:Type/@V='SYKM']">
						<li>
							<xsl:variable name="temp180" select="concat('SYKM',$position)"/>
							<a href="#{$temp180}">Sykemelding</a>
						</li>
					</xsl:if>
					<xsl:if test="//h:ServReq/h:Comment">
						<li>
							<xsl:variable name="temp190" select="concat('Comment',$position)"/>
							<a href="#{$temp190}">Kommentarer</a>
						</li>
					</xsl:if>
					<xsl:for-each select="//h:Patient">
						<xsl:if test="h:BasisForHealthServices or h:Sex or h:DateOfBirth or h:PatientPrecaution or po:AssistertKommunikasjon or po:ParorendeForesatt or h:ContactPerson or h:PatRelInst or h:Consent or h:AdditionalId">
							<li>
								<xsl:variable name="temp200" select="concat('Patient',$position)"/>
								<a href="#{$temp200}">Pasient</a>
							</li>
						</xsl:if>
						<xsl:if test="h:PatRelHCP">
							<li>
								<xsl:variable name="temp210" select="concat('PatRelHCP',$position)"/>
								<a href="#{$temp210}">Helsetjenesteenheter</a>
							</li>
						</xsl:if>
					</xsl:for-each>
					<xsl:if test="h:RefDoc">
						<li>
							<xsl:variable name="temp220" select="concat('RefDoc',$position)"/>
							<a href="#{$temp220}">Vedlegg</a>
						</li>
					</xsl:if>
				</ul>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="h:ServReq">
		<tr>
			<xsl:if test="h:IssueDate">
				<th>Utstedt</th>
				<td width="{((($std-col)-2)*number(not(h:PaymentCat | h:Ack))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(h:PaymentCat | h:Ack))+1}">
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="h:IssueDate/@V"/>
					</xsl:call-template>
				</td>
			</xsl:if>
			<xsl:if test="h:PaymentCat">
				<th>Betalingskategori</th>
				<td width="{((($std-col)-2-count(h:IssueDate)*2)*number(not(h:Ack))+1)*$std-td}px" colspan="{(($std-col)-2-count(h:IssueDate)*2)*number(not(h:Ack))+1}">
					<xsl:for-each select="h:PaymentCat">
						<xsl:call-template name="k-8246"/>&#160;</xsl:for-each>
				</td>
			</xsl:if>
			<xsl:if test="h:Ack">
				<th>Meldingsbekreftelse</th>
				<td colspan="{($std-col)-2-count(h:IssueDate | h:PaymentCat)*2}">
					<xsl:for-each select="h:Ack">
						<xsl:call-template name="k-7304"/>&#160;</xsl:for-each>
				</td>
			</xsl:if>
		</tr>
		<xsl:for-each select="h:ReqServ">
			<xsl:if test="h:Priority or h:Purpose or h:ReqDate">
				<tr>
					<xsl:if test="h:Priority">
						<th>Hastegrad</th>
						<td width="{((($std-col)-2)*number(not(h:Purpose | h:ReqDate))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(h:Purpose | h:ReqDate))+1}">
							<xsl:for-each select="h:Priority">
								<xsl:call-template name="k-8304"/>&#160;
							</xsl:for-each>
						</td>
					</xsl:if>
					<xsl:if test="h:Purpose">
						<th>Formål</th>
						<td width="{((($std-col)-2-count(h:Priority)*2)*number(not(h:ReqDate))+1)*$std-td}px" colspan="{(($std-col)-2-count(h:Priority)*2)*number(not(h:ReqDate))+1}">
							<xsl:for-each select="h:Purpose">
								<xsl:call-template name="k-8248"/>&#160;
							</xsl:for-each>
						</td>
					</xsl:if>
					<xsl:if test="h:ReqDate">
						<th>Utstedt</th>
						<td colspan="{($std-col)-1-count(h:Priority | h:Purpose)*2}">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="h:ReqDate/@V"/>
							</xsl:call-template>
						</td>
					</xsl:if>
				</tr>
			</xsl:if>
			<xsl:for-each select="h:Service">
				<xsl:if test="h:ServId or h:MedSpeciality or h:AdmCat">
					<tr>
						<xsl:if test="h:ServId">
							<th>Spesifisert&#160;tjeneste</th>
							<td width="{((($std-col)-2)*number(not(h:MedSpeciality | h:AdmCat))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(h:MedSpeciality | h:AdmCat))+1}">
								<xsl:for-each select="h:ServId">
									<xsl:choose>
										<xsl:when test="@DN or @OT">
											<xsl:call-template name="k-dummy"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="@V"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</td>
						</xsl:if>
						<xsl:if test="h:MedSpeciality">
							<th>Medisinsk spesialitet</th>
							<td width="{((($std-col)-2-count(h:ServId)*2)*number(not(h:AdmCat))+1)*$std-td}px" colspan="{(($std-col)-2-count(h:ServId)*2)*number(not(h:AdmCat))+1}">
								<xsl:for-each select="h:MedSpeciality">
									<xsl:choose>
										<xsl:when test="contains(@S,'7426')">
											<xsl:call-template name="k-7426"/>
										</xsl:when>
										<xsl:when test="contains(@S,'8451')">
											<xsl:call-template name="k-8451"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="k-dummy"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</td>
						</xsl:if>
						<xsl:if test="h:AdmCat">
							<th>Type tjeneste</th>
							<td colspan="{($std-col)-2-count(h:ServId | h:MedSpeciality)*2}">
								<xsl:for-each select="h:AdmCat">
									<xsl:call-template name="k-8240"/>&#160;
								</xsl:for-each>
							</td>
						</xsl:if>
					</tr>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="h:Comment">
				<tr>
					<td colspan="{$std-col}">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="h:Comment"/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="h:ReqComment">
			<tr>
				<td colspan="{$std-col}">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="h:ReqComment"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
	<xsl:template match="h:Diagnosis">
		<tr>
			<th>
				<xsl:value-of select="h:Concept/@V"/>&#160;
				<xsl:if test="contains(h:Concept/@S, '7170')">(ICPC)</xsl:if>
				<xsl:if test="contains(h:Concept/@S, '7110')">(ICD-10)</xsl:if>
			</th>
			<td width="{((($std-col)-2)*number(not(h:Modifier))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(h:Modifier))+1}">
				<xsl:if test="h:Concept/@DN or h:Concept/@OT">
					<xsl:for-each select="h:Concept">
						<xsl:call-template name="k-dummy"/>
					</xsl:for-each>
				</xsl:if>
			</td>
			<xsl:if test="h:Modifier">
				<td colspan="{($std-col)-2}">
					<xsl:for-each select="h:Modifier">
						<div>
							<span class="strong">
								<xsl:call-template name="k-7305"/>&#160;</span>
							<xsl:value-of select="h:Value/@V"/>&#160;-&#160;<xsl:value-of select="h:Value/@DN"/>
						</div>
					</xsl:for-each>
				</td>
			</xsl:if>
		</tr>
	</xsl:template>
	<xsl:template match="h:ReasonAsText">
		<tr>
			<xsl:if test="h:Heading/@V='BG' or h:Heading/@V='BUP-BM' or h:Heading/@V='BUP-HG' or h:Heading/@V='KF' or h:Heading/@V='MAAL' or h:Heading/@V='MU' or h:Heading/@V='RU' or h:Heading/@V='UP'">
				<th>
					<xsl:for-each select="h:Heading">
						<xsl:call-template name="k-8231"/>
					</xsl:for-each>
					<xsl:if test="not(h:Heading)">Begrunnelse&#160;(uspes.)</xsl:if>
				</th>
			</xsl:if>
			<td colspan="{($std-col)-1}">
				<xsl:if test="h:TextResultValue">
					<div>
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="h:TextResultValue"/>
						</xsl:call-template>
					</div>
				</xsl:if>
				<xsl:for-each select="h:TextCode">
					<div>
						<xsl:choose>
							<xsl:when test="@DN">
								<xsl:value-of select="@DN"/>&#160;</xsl:when>
							<xsl:when test="@OT">
								<xsl:value-of select="@OT"/>&#160;</xsl:when>
							<xsl:when test="@V">
								<xsl:value-of select="@V"/>&#160;<xsl:choose>
									<xsl:when test="contains(@S,'7010')">(SNOMED)</xsl:when>
									<xsl:when test="contains(@S,'7230')">(NKKKL)</xsl:when>
									<xsl:when test="contains(@S,'7240')">(NORAKO)</xsl:when>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
					</div>
				</xsl:for-each>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="h:Observation">
		<tr>
			<td width="{((($std-col)-1)*number(not(../h:StartDateTime | ../h:EndDateTime | ../h:OrgDate))+1)*$std-td}px" colspan="{(($std-col)-1)*number(not(../h:StartDateTime | ../h:EndDateTime | ../h:OrgDate))+1}">
				<xsl:if test="h:Description">
					<div>
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="h:Description"/>
						</xsl:call-template>
					</div>
				</xsl:if>
				<xsl:if test="h:Comment">
					<div>
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="h:Comment"/>
						</xsl:call-template>
					</div>
				</xsl:if>
			</td>
			<xsl:if test="../h:StartDateTime or ../h:EndDateTime or ../h:OrgDate">
				<td colspan="{($std-col)-1}">
					<xsl:if test="../h:StartDateTime">
						<div>Start:&#160;
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../h:StartDateTime/@V"/>
							</xsl:call-template>
						</div>
					</xsl:if>
					<xsl:if test="../h:EndDateTime">
						<div>Slutt:&#160;
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../h:EndDateTime/@V"/>
							</xsl:call-template>
						</div>
					</xsl:if>
					<xsl:if test="../h:OrgDate">
						<div>Opprinnelse:&#160;
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../h:OrgDate/@V"/>
							</xsl:call-template>
						</div>
					</xsl:if>
				</td>
			</xsl:if>
		</tr>
	</xsl:template>
	<xsl:template match="h:ResultItem">
		<td>
			<xsl:for-each select="h:ClinInv">
				<div>
					<xsl:for-each select="h:Id">
						<xsl:call-template name="k-dummy"/>
					</xsl:for-each>
				</div>
				<xsl:for-each select="h:Spec">
					<div>
						<span class="strong">Spesifisert:</span>&#160;
						<xsl:call-template name="k-dummy"/>
					</div>
				</xsl:for-each>
			</xsl:for-each>
		</td>
		<td width="{$res-res-col*$std-td}px" colspan="{$res-res-col}">
			<xsl:for-each select="h:Interval">
				<xsl:if test="h:Low">
					<span class="strong">Nedre:</span>&#160;<xsl:value-of select="h:Low/@V"/>
					<xsl:value-of select="h:Low/@U"/>&#160;</xsl:if>
				<xsl:if test="h:High">
					<span class="strong">Øvre:</span>&#160;<xsl:value-of select="h:High/@V"/>
					<xsl:value-of select="h:High/@U"/>&#160;</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="h:DateResult">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="h:DateResultValue/@V"/>
				</xsl:call-template>
			</xsl:for-each>
			<xsl:for-each select="h:NumResult">
				<xsl:for-each select="h:ArithmeticComp">
					<xsl:call-template name="k-8239"/>
				</xsl:for-each>
				<xsl:value-of select="h:NumResultValue/@V"/>&#160;<xsl:value-of select="h:NumResultValue/@U"/>&#160;
				<xsl:for-each select="../h:DevResultInd">
					<span class="strong">
						<xsl:call-template name="k-8244"/>
					</span>
				</xsl:for-each>
			</xsl:for-each>
			<xsl:for-each select="h:TextResult/h:Result">
				<xsl:if test="h:TextResultValue">
					<div>
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="h:TextResultValue"/>
						</xsl:call-template>
					</div>
				</xsl:if>
				<xsl:if test="h:TextCode">
					<div>
						<xsl:call-template name="k-dummy"/>
					</div>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="h:Comment">
				<div>
					<span class="strong">Kommentar:</span>&#160;<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="h:Comment"/>
					</xsl:call-template>
				</div>
			</xsl:if>
		</td>
		<xsl:if test="//h:ResultItem/h:InvDate">
			<td width="{$res-idate-col*$std-td}px" colspan="{$res-idate-col}">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="h:InvDate/@V"/>
				</xsl:call-template>
			</td>
		</xsl:if>
		<xsl:if test="//h:InfItem[h:ResultItem]/h:StartDateTime">
			<td width="{$res-sdate-col*$std-td}px" colspan="{$res-sdate-col}">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../h:StartDateTime/@V"/>
				</xsl:call-template>
			</td>
		</xsl:if>
		<xsl:if test="//h:InfItem[h:ResultItem]/h:EndDateTime">
			<td width="{$res-edate-col*$std-td}px" colspan="{$res-edate-col}">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../h:EndDateTime/@V"/>
				</xsl:call-template>
			</td>
		</xsl:if>
		<xsl:if test="//h:InfItem[h:ResultItem]/h:OrgDate">
			<td colspan="{$res-odate-col}">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../h:OrgDate/@V"/>
				</xsl:call-template>
			</td>
		</xsl:if>
	</xsl:template>
	<xsl:template match="h:Medication">
		<td>
			<xsl:for-each select="h:DrugId">
				<xsl:call-template name="k-dummy"/>
			</xsl:for-each>
		</td>
		<td width="{$med-stat-col*$std-td}px" colspan="{$med-stat-col}">
			<xsl:for-each select="h:Status">
				<xsl:call-template name="k-7307"/>&#160;
			</xsl:for-each>
		</td>
		<xsl:if test="//h:Medication/h:UnitDose or //h:Medication/h:QuantitySupplied">
			<td width="{$med-unit-col*$std-td}px" colspan="{$med-unit-col}">
				<xsl:if test="h:UnitDose">
					<xsl:value-of select="h:UnitDose/@V"/>&#160;<xsl:value-of select="h:UnitDose/@U"/>
					<xsl:if test="h:QuantitySupplied">&#160;x&#160;</xsl:if>
				</xsl:if>
				<xsl:if test="h:QuantitySupplied">
					<xsl:value-of select="h:QuantitySupplied/@V"/>&#160;<xsl:value-of select="h:QuantitySupplied/@U"/>
				</xsl:if>&#160;
			</td>
		</xsl:if>
		<xsl:if test="//h:Medication/h:DosageText or //h:Medication/h:IntendedDuration">
			<td width="{$med-text-col*$std-td}px" colspan="{$med-text-col}">
				<xsl:if test="h:DosageText">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="h:DosageText"/>
					</xsl:call-template>
				</xsl:if>&#160;
				<xsl:if test="h:IntendedDuration">&#160;/&#160;<xsl:value-of select="h:IntendedDuration/@V"/>&#160;<xsl:value-of select="h:IntendedDuration/@U"/>
				</xsl:if>
				<xsl:if test="not(h:DosageText) and not(h:IntendedDuration)">&#160;</xsl:if>
			</td>
		</xsl:if>
		<xsl:if test="//h:Medication/h:Comment">
			<td width="{$med-com-col*$std-td}px" colspan="{$med-com-col}">
				<xsl:call-template name="line-breaks">
					<xsl:with-param name="text" select="h:Comment"/>
				</xsl:call-template>
			</td>
		</xsl:if>
		<xsl:if test="//h:InfItem[h:Medication]/h:StartDateTime">
			<td width="{$med-sdate-col*$std-td}px" colspan="{$med-sdate-col}">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../h:StartDateTime/@V"/>
				</xsl:call-template>
			</td>
		</xsl:if>
		<xsl:if test="//h:InfItem[h:Medication]/h:EndDateTime">
			<td width="{$med-edate-col*$std-td}px" colspan="{$med-edate-col}">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../h:EndDateTime/@V"/>
				</xsl:call-template>
			</td>
		</xsl:if>
		<xsl:if test="//h:InfItem[h:Medication]/h:OrgDate">
			<td colspan="{$med-odate-col}">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../h:OrgDate/@V"/>
				</xsl:call-template>
			</td>
		</xsl:if>
	</xsl:template>
	<xsl:template match="h:Patient" mode="full">
		<xsl:if test="h:BasisForHealthServices or h:Sex or h:DateOfBirth or h:AdditionalId">
			<tr>
				<th rowspan="2">Pasientinfo</th>
				<xsl:if test="h:Name">
					<th colspan="{(($std-col)-2)*number(not(h:OffId | h:Sex | h:DateOfBirth | h:DateOfDeath | h:BasisForHealthServices | h:AdditionalId ))+1}">Navn</th>
				</xsl:if>
				<xsl:if test="h:OffId">
					<th colspan="{(($std-col)-2-count(h:Name))*number(not(h:Sex | h:DateOfBirth | h:DateOfDeath | h:BasisForHealthServices | h:AdditionalId))+1}">
						<xsl:for-each select="h:TypeOffId">
							<xsl:call-template name="k-8116"/>&#160;
						</xsl:for-each>
					</th>
				</xsl:if>
				<xsl:if test="h:Sex">
					<th colspan="{(($std-col)-2-count(h:Name | h:OffId))*number(not(h:DateOfBirth | h:DateOfDeath | h:BasisForHealthServices | h:AdditionalId))+1}">Kjønn</th>
				</xsl:if>
				<xsl:if test="h:DateOfBirth">
					<th colspan="{(($std-col)-2-count(h:Name | h:OffId | h:Sex))*number(not(h:DateOfDeath | h:BasisForHealthServices | h:AdditionalId))+1}">Fødselsdag</th>
				</xsl:if>
				<xsl:if test="h:DateOfDeath">
					<th colspan="{(($std-col)-2-count(h:Name | h:OffId | h:Sex | h:DateOfBirth))*number(not(h:BasisForHealthServices | h:AdditionalId))+1}">Dødsdag</th>
				</xsl:if>
				<xsl:if test="h:BasisForHealthServices">
					<th colspan="{(($std-col)-2-count(h:Name | h:OffId | h:Sex | h:DateOfBirth | h:DateOfDeath))*number(not(h:AdditionalId))+1}">Refusjonsgrunnlag</th>
				</xsl:if>
				<xsl:if test="h:AdditionalId">
					<th colspan="{(($std-col)-1-count(h:Name | h:OffId | h:Sex | h:DateOfBirth | h:DateOfDeath | h:BasisForHealthServices))}">Tilleggs-Id</th>
				</xsl:if>
			</tr>
			<tr>
				<xsl:if test="h:Name">
					<td width="{((($std-col)-2)*number(not(h:OffId | h:Sex | h:DateOfBirth | h:DateOfDeath | h:BasisForHealthServices | h:AdditionalId ))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(h:OffId | h:Sex | h:DateOfBirth | h:DateOfDeath | h:BasisForHealthServices | h:AdditionalId ))+1}">
						<xsl:value-of select="h:Name"/>
					</td>
				</xsl:if>
				<xsl:if test="h:OffId">
					<td width="{((($std-col)-2-count(h:Name))*number(not(h:Sex | h:DateOfBirth | h:DateOfDeath | h:BasisForHealthServices | h:AdditionalId))+1)*$std-td}px" colspan="{(($std-col)-2-count(h:Name))*number(not(h:Sex | h:DateOfBirth | h:DateOfDeath | h:BasisForHealthServices | h:AdditionalId))+1}">
						<xsl:value-of select="h:OffId"/>
					</td>
				</xsl:if>
				<xsl:if test="h:Sex">
					<td width="{((($std-col)-2-count(h:Name | h:OffId))*number(not(h:DateOfBirth | h:DateOfDeath | h:BasisForHealthServices | h:AdditionalId))+1)*$std-td}px" colspan="{(($std-col)-2-count(h:Name | h:OffId))*number(not(h:DateOfBirth | h:DateOfDeath | h:BasisForHealthServices | h:AdditionalId))+1}">
						<xsl:for-each select="h:Sex">
							<xsl:call-template name="k-3101"/>&#160;
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="h:DateOfBirth">
					<td width="{((($std-col)-2-count(h:Name | h:OffId | h:Sex))*number(not(h:DateOfDeath | h:BasisForHealthServices | h:AdditionalId))+1)*$std-td}px" colspan="{(($std-col)-2-count(h:Name | h:OffId | h:Sex))*number(not(h:DateOfDeath | h:BasisForHealthServices | h:AdditionalId))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="h:DateOfBirth/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="h:DateOfDeath">
					<td width="{((($std-col)-2-count(h:Name | h:OffId | h:Sex | h:DateOfBirth))*number(not(h:BasisForHealthServices | h:AdditionalId))+1)*$std-td}px" colspan="{(($std-col)-2-count(h:Name | h:OffId | h:Sex | h:DateOfBirth))*number(not(h:BasisForHealthServices | h:AdditionalId))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="h:DateOfDeath/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="h:BasisForHealthServices">
					<td width="{((($std-col)-2-count(h:Name | h:OffId | h:Sex | h:DateOfBirth | h:DateOfDeath))*number(not(h:AdditionalId))+1)*$std-td}px" colspan="{(($std-col)-2-count(h:Name | h:OffId | h:Sex | h:DateOfBirth | h:DateOfDeath))*number(not(h:AdditionalId))+1}">
						<xsl:for-each select="h:BasisForHealthServices">
							<xsl:call-template name="k-8246"/>&#160;
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="h:AdditionalId">
					<td colspan="{(($std-col)-1-count(h:Name | h:OffId | h:Sex | h:DateOfBirth | h:DateOfDeath | h:BasisForHealthServices))}">
						<xsl:for-each select="h:AdditionalId">
							<div>
								<xsl:if test="h:Type">
									<span class="strong">
										<xsl:value-of select="h:Type/@V"/>:</span>&#160;</xsl:if>
								<xsl:value-of select="h:Id"/>
							</div>
						</xsl:for-each>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:for-each select="h:PatientPrecaution">
			<xsl:if test="position()=1">
				<tr>
					<td colspan="{$std-col}">
						<hr/>
					</td>
				</tr>
				<tr>
					<th rowspan="{last()+1}">Advarsel til tjenesteyter</th>
					<xsl:if test="..//h:PatientPrecaution/h:Precaution">
						<th colspan="{(($std-col)-2)*number(not(..//h:PatientPrecaution/h:StartDateTime | ..//h:PatientPrecaution/h:EndDateTime))+1}">Advarsel</th>
					</xsl:if>
					<xsl:if test="..//h:PatientPrecaution/h:StartDateTime">
						<th colspan="{(($std-col)-2-number(boolean(..//h:PatientPrecaution/h:Precaution)))*number(not(..//h:PatientPrecaution/h:EndDateTime))+1}">Starttidspunkt</th>
					</xsl:if>
					<xsl:if test="..//h:PatientPrecaution/h:EndDateTime">
						<th colspan="{(($std-col)-1-number(boolean(..//h:PatientPrecaution/h:Precaution))-number(boolean(..//h:PatientPrecaution/h:StartDateTime)))}">Sluttidspunkt</th>
					</xsl:if>
				</tr>
			</xsl:if>
			<tr>
				<xsl:if test="..//h:PatientPrecaution/h:Precaution">
					<td width="{((($std-col)-2)*number(not(..//h:PatientPrecaution/h:StartDateTime | ..//h:PatientPrecaution/h:EndDateTime))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(..//h:PatientPrecaution/h:StartDateTime | ..//h:PatientPrecaution/h:EndDateTime))+1}">
						<xsl:value-of select="h:Precaution"/>&#160;
					</td>
				</xsl:if>
				<xsl:if test="..//h:PatientPrecaution/h:StartDateTime">
					<td width="{((($std-col)-2-number(boolean(..//h:PatientPrecaution/h:Precaution)))*number(not(..//h:PatientPrecaution/h:EndDateTime))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//h:PatientPrecaution/h:Precaution)))*number(not(..//h:PatientPrecaution/h:EndDateTime))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="h:StartDateTime/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="..//h:PatientPrecaution/h:EndDateTime">
					<td colspan="{(($std-col)-1-number(boolean(..//h:PatientPrecaution/h:Precaution))-number(boolean(..//h:PatientPrecaution/h:StartDateTime)))}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="h:EndDateTime/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="h:Consent">
			<tr>
				<td colspan="{$std-col}">
					<hr/>
				</td>
			</tr>
			<tr>
				<th rowspan="2">Samtykke</th>
				<xsl:if test="h:ConsentStatus">
					<th colspan="{(($std-col)-2)*number(not(h:ConsentDate | h:Merknad | h:GivenBy))+1}">Samtykke&#160;gitt</th>
				</xsl:if>
				<xsl:if test="h:ConsentDate">
					<th colspan="{(($std-col)-2-count(h:ConsentStatus))*number(not(h:Merknad | h:GivenBy))+1}">Samtykkedato</th>
				</xsl:if>
				<xsl:if test="h:Merknad">
					<th colspan="{(($std-col)-2-count(h:ConsentStatus | h:ConsentDate))*number(not(h:GivenBy))+1}">Merknad</th>
				</xsl:if>
				<xsl:if test="h:GivenBy">
					<th colspan="{(($std-col)-1-count(h:ConsentStatus | h:ConsentDate | h:Merknad))}">Gitt&#160;av</th>
				</xsl:if>
			</tr>
			<tr>
				<xsl:if test="h:ConsentStatus">
					<td width="{((($std-col)-2)*number(not(h:ConsentDate | h:Merknad | h:GivenBy))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(h:ConsentDate | h:Merknad | h:GivenBy))+1}">
						<xsl:for-each select="h:ConsentStatus">
							<xsl:call-template name="k-3109"/>&#160;
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="h:ConsentDate">
					<td width="{((($std-col)-2-count(h:ConsentStatus))*number(not(h:Merknad | h:GivenBy))+1)*$std-td}px" colspan="{(($std-col)-2-count(h:ConsentStatus))*number(not(h:Merknad | h:GivenBy))+1}">
						<xsl:call-template name="skrivUtDate">
							<xsl:with-param name="oppgittTid" select="h:ConsentDate"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="h:Merknad">
					<td width="{((($std-col)-2-count(h:ConsentStatus | h:ConsentDate))*number(not(h:GivenBy))+1)*$std-td}px" colspan="{(($std-col)-2-count(h:ConsentStatus | h:ConsentDate))*number(not(h:GivenBy))+1}">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="h:Merknad"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="h:GivenBy">
					<td colspan="{(($std-col)-1-count(h:ConsentStatus | h:ConsentDate | h:Merknad))}">
						<xsl:value-of select="h:GivenBy"/>
					</td>
				</xsl:if>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="po:AssistertKommunikasjon">
			<xsl:if test="position()=1">
				<tr>
					<td colspan="{$std-col}">
						<hr/>
					</td>
				</tr>
				<tr>
					<th rowspan="{(last()+1)}">Behov&#160;for&#160;tolk</th>
					<xsl:if test="..//po:AssistertKommunikasjon/po:PersonTolkebehov">
						<th colspan="{(($std-col)-2)*number(not(..//po:AssistertKommunikasjon/po:Horselsvikt | ..//po:AssistertKommunikasjon/po:Synsvikt | ..//po:AssistertKommunikasjon/po:BehovTolkSprak | ..//po:AssistertKommunikasjon/po:PreferertTolk | ..//po:AssistertKommunikasjon/po:BehovOpphortDato | ..//po:AssistertKommunikasjon/po:Merknad))+1}">Personen&#160;behovet&#160;gjelder</th>
					</xsl:if>
					<xsl:if test="..//po:AssistertKommunikasjon[po:Horselsvikt='true'] or ..//po:AssistertKommunikasjon[po:Synsvikt='true']">
						<th colspan="{(($std-col)-2-number(boolean(..//po:AssistertKommunikasjon/po:PersonTolkebehov)))*number(not(..//po:AssistertKommunikasjon/po:BehovTolkSprak | ..//po:AssistertKommunikasjon/po:PreferertTolk | ..//po:AssistertKommunikasjon/po:BehovOpphortDato | ..//po:AssistertKommunikasjon/po:Merknad))+1}">Handikap</th>
					</xsl:if>
					<xsl:if test="..//po:AssistertKommunikasjon/po:BehovTolkSprak">
						<th colspan="{(($std-col)-2-number(boolean(..//po:AssistertKommunikasjon/po:PersonTolkebehov))-number(boolean(..//po:AssistertKommunikasjon/po:Horselsvikt | ..//po:AssistertKommunikasjon/po:Synsvikt)))*number(not(..//po:AssistertKommunikasjon/po:PreferertTolk | ..//po:AssistertKommunikasjon/po:BehovOpphortDato | ..//po:AssistertKommunikasjon/po:Merknad))+1}">Behov for tolk - Språk</th>
					</xsl:if>
					<xsl:if test="..//po:AssistertKommunikasjon/po:PreferertTolk">
						<th colspan="{(($std-col)-2-number(boolean(..//po:AssistertKommunikasjon/po:PersonTolkebehov))-number(boolean(..//po:AssistertKommunikasjon/po:Horselsvikt | ..//po:AssistertKommunikasjon/po:Synsvikt))-number(boolean(..//po:AssistertKommunikasjon/po:BehovTolkSprak)))*number(not(..//po:AssistertKommunikasjon/po:BehovOpphortDato | ..//po:AssistertKommunikasjon/po:Merknad))+1}">Foretrukket&#160;tolk</th>
					</xsl:if>
					<xsl:if test="..//po:AssistertKommunikasjon/po:BehovOpphortDato">
						<th colspan="{(($std-col)-2-number(boolean(..//po:AssistertKommunikasjon/po:PersonTolkebehov))-number(boolean(..//po:AssistertKommunikasjon/po:Horselsvikt | ..//po:AssistertKommunikasjon/po:Synsvikt))-number(boolean(..//po:AssistertKommunikasjon/po:BehovTolkSprak))-number(boolean(..//po:AssistertKommunikasjon/po:PreferertTolk)))*number(not(..//po:AssistertKommunikasjon/po:Merknad))+1}">Behov&#160;opphørt&#160;dato</th>
					</xsl:if>
					<xsl:if test="..//po:AssistertKommunikasjon/po:Merknad">
						<th colspan="{(($std-col)-1-number(boolean(..//po:AssistertKommunikasjon/po:PersonTolkebehov))-number(boolean(..//po:AssistertKommunikasjon/po:Horselsvikt | ..//po:AssistertKommunikasjon/po:Synsvikt))-number(boolean(..//po:AssistertKommunikasjon/po:BehovTolkSprak))-number(boolean(..//po:AssistertKommunikasjon/po:PreferertTolk))-number(boolean(..//po:AssistertKommunikasjon/po:BehovOpphortDato)))}">Merknad</th>
					</xsl:if>
				</tr>
			</xsl:if>
			<tr>
				<xsl:if test="..//po:AssistertKommunikasjon/po:PersonTolkebehov">
					<td width="{((($std-col)-2)*number(not(..//po:AssistertKommunikasjon/po:Horselsvikt | ..//po:AssistertKommunikasjon/po:Synsvikt | ..//po:AssistertKommunikasjon/po:BehovTolkSprak | ..//po:AssistertKommunikasjon/po:PreferertTolk | ..//po:AssistertKommunikasjon/po:BehovOpphortDato | ..//po:AssistertKommunikasjon/po:Merknad))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(..//po:AssistertKommunikasjon/po:Horselsvikt | ..//po:AssistertKommunikasjon/po:Synsvikt | ..//po:AssistertKommunikasjon/po:BehovTolkSprak | ..//po:AssistertKommunikasjon/po:PreferertTolk | ..//po:AssistertKommunikasjon/po:BehovOpphortDato | ..//po:AssistertKommunikasjon/po:Merknad))+1}">
						<xsl:for-each select="po:PersonTolkebehov">
							<div>
								<xsl:value-of select="fk1:FamilyName"/>,&#160;<xsl:value-of select="fk1:GivenName"/>&#160;<xsl:value-of select="fk1:MiddleName"/>
							</div>
							<xsl:for-each select=".//fk1:TeleAddress">
								<xsl:call-template name="h:TeleAddress"/>
							</xsl:for-each>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="..//po:AssistertKommunikasjon[po:Horselsvikt='true'] or ..//po:AssistertKommunikasjon[po:Synsvikt='true']">
					<td width="{((($std-col)-2-number(boolean(..//po:AssistertKommunikasjon/po:PersonTolkebehov)))*number(not(..//po:AssistertKommunikasjon/po:BehovTolkSprak | ..//po:AssistertKommunikasjon/po:PreferertTolk | ..//po:AssistertKommunikasjon/po:BehovOpphortDato | ..//po:AssistertKommunikasjon/po:Merknad))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//po:AssistertKommunikasjon/po:PersonTolkebehov)))*number(not(..//po:AssistertKommunikasjon/po:BehovTolkSprak | ..//po:AssistertKommunikasjon/po:PreferertTolk | ..//po:AssistertKommunikasjon/po:BehovOpphortDato | ..//po:AssistertKommunikasjon/po:Merknad))+1}">
						<xsl:if test="po:Horselsvikt='true'">Døv</xsl:if>
						<xsl:if test="po:Horselsvikt='true' and po:Synsvikt='true'">&#160;og&#160;</xsl:if>
						<xsl:if test="po:Synsvikt='true'">Blind</xsl:if>&#160;
					</td>
				</xsl:if>
				<xsl:if test="..//po:AssistertKommunikasjon/po:BehovTolkSprak">
					<td width="{((($std-col)-2-number(boolean(..//po:AssistertKommunikasjon/po:PersonTolkebehov))-number(boolean(..//po:AssistertKommunikasjon/po:Horselsvikt | ..//po:AssistertKommunikasjon/po:Synsvikt)))*number(not(..//po:AssistertKommunikasjon/po:PreferertTolk | ..//po:AssistertKommunikasjon/po:BehovOpphortDato | ..//po:AssistertKommunikasjon/po:Merknad))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//po:AssistertKommunikasjon/po:PersonTolkebehov))-number(boolean(..//po:AssistertKommunikasjon/po:Horselsvikt | ..//po:AssistertKommunikasjon/po:Synsvikt)))*number(not(..//po:AssistertKommunikasjon/po:PreferertTolk | ..//po:AssistertKommunikasjon/po:BehovOpphortDato | ..//po:AssistertKommunikasjon/po:Merknad))+1}">
						<xsl:for-each select="po:BehovTolkSprak">
							<xsl:call-template name="k-3303"/>&#160;
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="..//po:AssistertKommunikasjon/po:PreferertTolk">
					<td width="{((($std-col)-2-number(boolean(..//po:AssistertKommunikasjon/po:PersonTolkebehov))-number(boolean(..//po:AssistertKommunikasjon/po:Horselsvikt | ..//po:AssistertKommunikasjon/po:Synsvikt))-number(boolean(..//po:AssistertKommunikasjon/po:BehovTolkSprak)))*number(not(..//po:AssistertKommunikasjon/po:BehovOpphortDato | ..//po:AssistertKommunikasjon/po:Merknad))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//po:AssistertKommunikasjon/po:PersonTolkebehov))-number(boolean(..//po:AssistertKommunikasjon/po:Horselsvikt | ..//po:AssistertKommunikasjon/po:Synsvikt))-number(boolean(..//po:AssistertKommunikasjon/po:BehovTolkSprak)))*number(not(..//po:AssistertKommunikasjon/po:BehovOpphortDato | ..//po:AssistertKommunikasjon/po:Merknad))+1}">
						<xsl:for-each select="po:PreferertTolk">
							<div>
								<xsl:value-of select="fk1:FamilyName"/>,&#160;<xsl:value-of select="fk1:GivenName"/>&#160;<xsl:value-of select="fk1:MiddleName"/>
							</div>
							<xsl:for-each select=".//fk1:TeleAddress">
								<xsl:call-template name="h:TeleAddress"/>
							</xsl:for-each>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="..//po:AssistertKommunikasjon/po:BehovOpphortDato">
					<td width="{((($std-col)-2-number(boolean(..//po:AssistertKommunikasjon/po:PersonTolkebehov))-number(boolean(..//po:AssistertKommunikasjon/po:Horselsvikt | ..//po:AssistertKommunikasjon/po:Synsvikt))-number(boolean(..//po:AssistertKommunikasjon/po:BehovTolkSprak))-number(boolean(..//po:AssistertKommunikasjon/po:PreferertTolk)))*number(not(..//po:AssistertKommunikasjon/po:Merknad))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//po:AssistertKommunikasjon/po:PersonTolkebehov))-number(boolean(..//po:AssistertKommunikasjon/po:Horselsvikt | ..//po:AssistertKommunikasjon/po:Synsvikt))-number(boolean(..//po:AssistertKommunikasjon/po:BehovTolkSprak))-number(boolean(..//po:AssistertKommunikasjon/po:PreferertTolk)))*number(not(..//po:AssistertKommunikasjon/po:Merknad))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="po:BehovOpphortDato/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="..//po:AssistertKommunikasjon/po:Merknad">
					<td colspan="{(($std-col)-1-number(boolean(..//po:AssistertKommunikasjon/po:PersonTolkebehov))-number(boolean(..//po:AssistertKommunikasjon/po:Horselsvikt | ..//po:AssistertKommunikasjon/po:Synsvikt))-number(boolean(..//po:AssistertKommunikasjon/po:BehovTolkSprak))-number(boolean(..//po:AssistertKommunikasjon/po:PreferertTolk))-number(boolean(..//po:AssistertKommunikasjon/po:BehovOpphortDato)))}">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="po:Merknad"/>
						</xsl:call-template>&#160;
					</td>
				</xsl:if>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="po:ParorendeForesatt">
			<xsl:if test="position()=1">
				<tr>
					<td colspan="{$std-col}">
						<hr/>
					</td>
				</tr>
				<tr>
					<th rowspan="{last()+1}">Pårørende/foresatt</th>
					<xsl:if test="..//po:ParorendeForesatt/po:Referanseperson">
						<th colspan="{(($std-col)-2)*number(not(..//po:ParorendeForesatt/po:Slektskap | ..//po:ParorendeForesatt/po:Omsorgsfunksjon | ..//po:ParorendeForesatt/po:Merknad))+1}">Person</th>
					</xsl:if>
					<xsl:if test="..//po:ParorendeForesatt/po:Slektskap">
						<th colspan="{(($std-col)-2-number(boolean(..//po:ParorendeForesatt/po:Referanseperson)))*number(not(..//po:ParorendeForesatt/po:Omsorgsfunksjon | ..//po:ParorendeForesatt/po:Merknad))+1}">Slektskap</th>
					</xsl:if>
					<xsl:if test="..//po:ParorendeForesatt/po:Omsorgsfunksjon">
						<th colspan="{(($std-col)-2-number(boolean(..//po:ParorendeForesatt/po:Referanseperson))-number(boolean(..//po:ParorendeForesatt/po:Slektskap)))*number(not(..//po:ParorendeForesatt/po:Merknad))+1}">Omsorgsfunksjon</th>
					</xsl:if>
					<xsl:if test="..//po:ParorendeForesatt/po:Merknad">
						<th colspan="{(($std-col)-1-number(boolean(..//po:ParorendeForesatt/po:Referanseperson))-number(boolean(..//po:ParorendeForesatt/po:Slektskap))-number(boolean(..//po:ParorendeForesatt/po:Omsorgsfunksjon)))}">Merknad</th>
					</xsl:if>
				</tr>
			</xsl:if>
			<tr>
				<xsl:if test="..//po:ParorendeForesatt/po:Referanseperson">
					<td width="{((($std-col)-2)*number(not(..//po:ParorendeForesatt/po:Slektskap | ..//po:ParorendeForesatt/po:Omsorgsfunksjon | ..//po:ParorendeForesatt/po:Merknad))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(..//po:ParorendeForesatt/po:Slektskap | ..//po:ParorendeForesatt/po:Omsorgsfunksjon | ..//po:ParorendeForesatt/po:Merknad))+1}">
						<xsl:for-each select="po:Referanseperson">
							<div>
								<xsl:value-of select="fk1:FamilyName"/>,&#160;<xsl:value-of select="fk1:GivenName"/>&#160;<xsl:value-of select="fk1:MiddleName"/>
							</div>
							<xsl:for-each select=".//fk1:TeleAddress">
								<xsl:call-template name="h:TeleAddress"/>
							</xsl:for-each>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="..//po:ParorendeForesatt/po:Slektskap">
					<td width="{((($std-col)-2-number(boolean(..//po:ParorendeForesatt/po:Referanseperson)))*number(not(..//po:ParorendeForesatt/po:Omsorgsfunksjon | ..//po:ParorendeForesatt/po:Merknad))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//po:ParorendeForesatt/po:Referanseperson)))*number(not(..//po:ParorendeForesatt/po:Omsorgsfunksjon | ..//po:ParorendeForesatt/po:Merknad))+1}">
						<xsl:for-each select="po:Slektskap">
							<xsl:call-template name="k-9033"/>&#160;
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="..//po:ParorendeForesatt/po:Omsorgsfunksjon">
					<td width="{((($std-col)-2-number(boolean(..//po:ParorendeForesatt/po:Referanseperson))-number(boolean(..//po:ParorendeForesatt/po:Slektskap)))*number(not(..//po:ParorendeForesatt/po:Merknad))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//po:ParorendeForesatt/po:Referanseperson))-number(boolean(..//po:ParorendeForesatt/po:Slektskap)))*number(not(..//po:ParorendeForesatt/po:Merknad))+1}">
						<xsl:for-each select="po:Omsorgsfunksjon">
							<xsl:call-template name="k-9050"/>&#160;
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="..//po:ParorendeForesatt/po:Merknad">
					<td colspan="{(($std-col)-1-number(boolean(..//po:ParorendeForesatt/po:Referanseperson))-number(boolean(..//po:ParorendeForesatt/po:Slektskap))-number(boolean(..//po:ParorendeForesatt/po:Omsorgsfunksjon)))}">
						<xsl:value-of select="po:Merknad"/>
					</td>
				</xsl:if>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="h:ContactPerson">
			<xsl:if test="position()=1">
				<tr>
					<td colspan="{$std-col}">
						<hr/>
					</td>
				</tr>
				<tr>
					<th rowspan="{last()+1}">Kontaktperson</th>
					<xsl:if test="..//h:ContactPerson/h:Referanseperson">
						<th colspan="{(($std-col)-2)*number(not(..//h:ContactPerson/h:OccupationRole | ..//h:ContactPerson/h:WorkingPlace | ..//h:ContactPerson/h:Merknad))+1}">Person</th>
					</xsl:if>
					<xsl:if test="..//h:ContactPerson/h:OccupationRole">
						<th colspan="{(($std-col)-2-number(boolean(..//h:ContactPerson/h:Referanseperson)))*number(not(..//h:ContactPerson/h:WorkingPlace | ..//h:ContactPerson/h:Merknad))+1}">Stilling/rolle</th>
					</xsl:if>
					<xsl:if test="..//h:ContactPerson/h:WorkingPlace">
						<th colspan="{(($std-col)-2-number(boolean(..//h:ContactPerson/h:Referanseperson))-number(boolean(..//h:ContactPerson/h:OccupationRole)))*number(not(..//h:ContactPerson/h:Merknad))+1}">Arbeidssted</th>
					</xsl:if>
					<xsl:if test="..//h:ContactPerson/h:Merknad">
						<th colspan="{(($std-col)-1-number(boolean(..//h:ContactPerson/h:Referanseperson))-number(boolean(..//h:ContactPerson/h:OccupationRole))-number(boolean(..//h:ContactPerson/h:WorkingPlace)))}">Merknad</th>
					</xsl:if>
				</tr>
			</xsl:if>
			<tr>
				<xsl:if test="..//h:ContactPerson/h:Referanseperson">
					<td width="{((($std-col)-2)*number(not(..//h:ContactPerson/h:OccupationRole | ..//h:ContactPerson/h:WorkingPlace | ..//h:ContactPerson/h:Merknad))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(..//h:ContactPerson/h:OccupationRole | ..//h:ContactPerson/h:WorkingPlace | ..//h:ContactPerson/h:Merknad))+1}">
						<xsl:for-each select="h:Referanseperson">
							<div>
								<xsl:value-of select="fk1:FamilyName"/>,&#160;<xsl:value-of select="fk1:GivenName"/>&#160;<xsl:value-of select="fk1:MiddleName"/>
							</div>
							<xsl:for-each select=".//fk1:TeleAddress">
								<xsl:call-template name="h:TeleAddress"/>
							</xsl:for-each>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="..//h:ContactPerson/h:OccupationRole">
					<td width="{((($std-col)-2-number(boolean(..//h:ContactPerson/h:Referanseperson)))*number(not(..//h:ContactPerson/h:WorkingPlace | ..//h:ContactPerson/h:Merknad))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//h:ContactPerson/h:Referanseperson)))*number(not(..//h:ContactPerson/h:WorkingPlace | ..//h:ContactPerson/h:Merknad))+1}">
						<xsl:value-of select="h:OccupationRole"/>
					</td>
				</xsl:if>
				<xsl:if test="..//h:ContactPerson/h:WorkingPlace">
					<td width="{((($std-col)-2-number(boolean(..//h:ContactPerson/h:Referanseperson))-number(boolean(..//h:ContactPerson/h:OccupationRole)))*number(not(..//h:ContactPerson/h:Merknad))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//h:ContactPerson/h:Referanseperson))-number(boolean(..//h:ContactPerson/h:OccupationRole)))*number(not(..//h:ContactPerson/h:Merknad))+1}">
						<xsl:value-of select="h:WorkingPlace"/>
					</td>
				</xsl:if>
				<xsl:if test="..//h:ContactPerson/h:Merknad">
					<td colspan="{(($std-col)-1-number(boolean(..//h:ContactPerson/h:Referanseperson))-number(boolean(..//h:ContactPerson/h:OccupationRole))-number(boolean(..//h:ContactPerson/h:WorkingPlace)))}">
						<xsl:value-of select="h:Merknad"/>
					</td>
				</xsl:if>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="h:PatRelInst">
			<xsl:if test="position()=1">
				<tr>
					<td colspan="{$std-col}">
						<hr/>
					</td>
				</tr>
				<tr>
					<th rowspan="{last()+1}">Referert virksomhet</th>
					<xsl:if test="..//h:PatRelInst/h:NameInst">
						<th colspan="{(($std-col)-2)*number(not(..//h:PatRelInst/h:RoleInst | ..//h:PatRelInst/h:ContactPerson | ..//h:PatRelInst/h:Merknad))+1}">Navn</th>
					</xsl:if>
					<xsl:if test="..//h:PatRelInst/h:RoleInst">
						<th colspan="{(($std-col)-2-number(boolean(..//h:PatRelInst/h:NameInst)))*number(not(..//h:PatRelInst/h:ContactPerson | ..//h:PatRelInst/h:Merknad))+1}">Rolle</th>
					</xsl:if>
					<xsl:if test="..//h:PatRelInst/h:ContactPerson">
						<th colspan="{(($std-col)-2-number(boolean(..//h:PatRelInst/h:NameInst))-number(boolean(..//h:PatRelInst/h:RoleInst)))*number(not(..//h:PatRelInst/h:Merknad))+1}">Kontaktperson</th>
					</xsl:if>
					<xsl:if test="..//h:PatRelInst/h:Merknad">
						<th colspan="{(($std-col)-1-number(boolean(..//h:PatRelInst/h:NameInst))-number(boolean(..//h:PatRelInst/h:RoleInst))-number(boolean(..//h:PatRelInst/h:ContactPerson)))}">Merknad</th>
					</xsl:if>
				</tr>
			</xsl:if>
			<tr>
				<xsl:if test="..//h:PatRelInst/h:NameInst">
					<td width="{((($std-col)-2)*number(not(..//h:PatRelInst/h:RoleInst | ..//h:PatRelInst/h:ContactPerson | ..//h:PatRelInst/h:Merknad))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(..//h:PatRelInst/h:RoleInst | ..//h:PatRelInst/h:ContactPerson | ..//h:PatRelInst/h:Merknad))+1}">
						<xsl:value-of select="h:NameInst"/>&#160;
					</td>
				</xsl:if>
				<xsl:if test="..//h:PatRelInst/h:RoleInst">
					<td width="{((($std-col)-2-number(boolean(..//h:PatRelInst/h:NameInst)))*number(not(..//h:PatRelInst/h:ContactPerson | ..//h:PatRelInst/h:Merknad))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//h:PatRelInst/h:NameInst)))*number(not(..//h:PatRelInst/h:ContactPerson | ..//h:PatRelInst/h:Merknad))+1}">
						<xsl:value-of select="h:RoleInst"/>&#160;
					</td>
				</xsl:if>
				<xsl:if test="..//h:PatRelInst/h:ContactPerson">
					<td width="{((($std-col)-2-number(boolean(..//h:PatRelInst/h:NameInst))-number(boolean(..//h:PatRelInst/h:RoleInst)))*number(not(..//h:PatRelInst/h:Merknad))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//h:PatRelInst/h:NameInst))-number(boolean(..//h:PatRelInst/h:RoleInst)))*number(not(..//h:PatRelInst/h:Merknad))+1}">
						<xsl:value-of select="h:ContactPerson"/>&#160;
					</td>
				</xsl:if>
				<xsl:if test="..//h:PatRelInst/h:Merknad">
					<td colspan="{(($std-col)-1-number(boolean(..//h:PatRelInst/h:NameInst))-number(boolean(..//h:PatRelInst/h:RoleInst))-number(boolean(..//h:PatRelInst/h:ContactPerson)))}">
						<xsl:value-of select="h:Merknad"/>&#160;
					</td>
				</xsl:if>
			</tr>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="h:PatRelHCP">
		<xsl:variable name="raw-rows" select="count(.//h:HCProf | .//h:HCPerson | .//h:Dept)"/>
		<xsl:variable name="rows">
			<xsl:choose>
				<xsl:when test="$raw-rows&gt;0">
					<xsl:value-of select="$raw-rows"/>
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<tr>
			<xsl:if test="..//h:PatRelHCP/h:Relation">
				<th rowspan="{$rows}">
					<xsl:for-each select="h:Relation">
						<xsl:call-template name="k-8254"/>&#160;
					</xsl:for-each>
				</th>
			</xsl:if>
			<xsl:if test="..//h:PatRelHCP//h:HCProf | ..//h:PatRelHCP//h:HCPerson | ..//h:PatRelHCP//h:Dept">
				<xsl:choose>
					<xsl:when test=".//h:HCProf | .//h:HCPerson | .//h:Dept">
						<xsl:for-each select=".//h:HCProf | .//h:HCPerson | .//h:Dept">
							<xsl:if test="position()=1">
								<xsl:apply-templates select="."/>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<td>&#160;</td>
						<td>&#160;</td>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="..//h:PatRelHCP//h:Inst/h:Name">
				<td rowspan="{$rows}" width="{((($std-col)-2-number(boolean(..//h:PatRelHCP//h:HCProf | ..//h:PatRelHCP//h:HCPerson | ..//h:PatRelHCP//h:Dept))-1)*number(not(..//h:PatRelHCP//h:MedSpeciality | ..//h:PatRelHCP//h:Inst/h:Id | ..//h:PatRelHCP/h:StartDateTime | ..//h:PatRelHCP/h:EndDateTime | ..//h:PatRelHCP//h:Address))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//h:PatRelHCP//h:HCProf | ..//h:PatRelHCP//h:HCPerson | ..//h:PatRelHCP//h:Dept))-1)*number(not(..//h:PatRelHCP//h:MedSpeciality | ..//h:PatRelHCP//h:Inst/h:Id | ..//h:PatRelHCP/h:StartDateTime | ..//h:PatRelHCP/h:EndDateTime | ..//h:PatRelHCP//h:Address))+1}">
					<xsl:value-of select=".//h:Inst/h:Name"/>&#160;
				</td>
			</xsl:if>
			<xsl:if test="..//h:PatRelHCP//h:MedSpeciality">
				<td rowspan="{$rows}" width="{((($std-col)-2-number(boolean(..//h:PatRelHCP//h:HCProf | ..//h:PatRelHCP//h:HCPerson | ..//h:PatRelHCP//h:Dept))-1-number(boolean(..//h:PatRelHCP//h:Inst/h:Name)))*number(not(..//h:PatRelHCP//h:Inst/h:Id | ..//h:PatRelHCP/h:StartDateTime | ..//h:PatRelHCP/h:EndDateTime | ..//h:PatRelHCP//h:Address))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//h:PatRelHCP//h:HCProf | ..//h:PatRelHCP//h:HCPerson | ..//h:PatRelHCP//h:Dept))-1-number(boolean(..//h:PatRelHCP//h:Inst/h:Name)))*number(not(..//h:PatRelHCP//h:Inst/h:Id | ..//h:PatRelHCP/h:StartDateTime | ..//h:PatRelHCP/h:EndDateTime | ..//h:PatRelHCP//h:Address))+1}">
					<xsl:for-each select=".//h:MedSpeciality">
						<xsl:call-template name="k-8451"/>&#160;
					</xsl:for-each>
				</td>
			</xsl:if>
			<xsl:if test="..//h:PatRelHCP//h:Inst/h:Id">
				<td rowspan="{$rows}" width="{((($std-col)-2-number(boolean(..//h:PatRelHCP//h:HCProf | ..//h:PatRelHCP//h:HCPerson | ..//h:PatRelHCP//h:Dept))-1-number(boolean(..//h:PatRelHCP//h:Inst/h:Name))-number(boolean(..//h:PatRelHCP//h:MedSpeciality)))*number(not(..//h:PatRelHCP/h:StartDateTime | ..//h:PatRelHCP/h:EndDateTime | ..//h:PatRelHCP//h:Address))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//h:PatRelHCP//h:HCProf | ..//h:PatRelHCP//h:HCPerson | ..//h:PatRelHCP//h:Dept))-1-number(boolean(..//h:PatRelHCP//h:Inst/h:Name))-number(boolean(..//h:PatRelHCP//h:MedSpeciality)))*number(not(..//h:PatRelHCP/h:StartDateTime | ..//h:PatRelHCP/h:EndDateTime | ..//h:PatRelHCP//h:Address))+1}">
					<xsl:if test=".//h:Inst/h:TypeId/@V">
						<span class="strong">
							<xsl:value-of select=".//h:Inst/h:TypeId/@V"/>:</span>
					</xsl:if>&#160;
					<xsl:value-of select=".//h:Inst/h:Id"/>
				</td>
			</xsl:if>
			<xsl:if test="..//h:PatRelHCP//h:StartDateTime | ..//h:PatRelHCP//h:EndDateTime">
				<td rowspan="{$rows}" width="{((($std-col)-2-number(boolean(..//h:PatRelHCP//h:HCProf | ..//h:PatRelHCP//h:HCPerson | ..//h:PatRelHCP//h:Dept))-1-number(boolean(..//h:PatRelHCP//h:Inst/h:Name))-number(boolean(..//h:PatRelHCP//h:MedSpeciality))-number(boolean(..//h:PatRelHCP//h:Inst/h:Id)))*number(not(..//h:PatRelHCP//h:Address))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//h:PatRelHCP//h:HCProf | ..//h:PatRelHCP//h:HCPerson | ..//h:PatRelHCP//h:Dept))-1-number(boolean(..//h:PatRelHCP//h:Inst/h:Name))-number(boolean(..//h:PatRelHCP//h:MedSpeciality))-number(boolean(..//h:PatRelHCP//h:Inst/h:Id)))*number(not(..//h:PatRelHCP//h:Address))+1}">
					<xsl:if test="h:StartDateTime">
						<span class="strong">Start:</span>&#160;
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="h:StartDateTime/@V"/>
						</xsl:call-template>
					</xsl:if>&#160;
					<xsl:if test="h:EndDateTime">
						<div>
							<span class="strong">Slutt:</span>&#160;
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="h:EndDateTime/@V"/>
							</xsl:call-template>
						</div>
					</xsl:if>
				</td>
			</xsl:if>
			<xsl:if test="..//h:PatRelHCP//h:Address">
				<td rowspan="{$rows}" colspan="{(($std-col)-1-number(boolean(..//h:PatRelHCP//h:HCProf | ..//h:PatRelHCP//h:HCPerson | ..//h:PatRelHCP//h:Dept))-1-number(boolean(..//h:PatRelHCP//h:Inst/h:Name))-number(boolean(..//h:PatRelHCP//h:MedSpeciality))-number(boolean(..//h:PatRelHCP//h:Inst/h:Id))-number(boolean(..//h:PatRelHCP/h:StartDateTime | ..//h:PatRelHCP/h:EndDateTime)))}">
					<xsl:apply-templates select=".//h:Address" mode="full"/>
				</td>
			</xsl:if>
		</tr>
		<xsl:for-each select=".//h:HCProf | .//h:HCPerson | .//h:Dept">
			<xsl:if test="position()!=1">
				<tr>
					<xsl:apply-templates select="."/>
				</tr>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="h:HCProf | h:HCPerson | h:Dept">
		<td width="{((($std-col)-2)*number(not(//h:PatRelHCP//h:HCProf/h:Id | //h:PatRelHCP//h:HCProf/h:AdditionalId | //h:PatRelHCP//h:HCPerson/h:Id | //h:PatRelHCP//h:HCPerson/h:AdditionalId | //h:PatRelHCP//h:Dept/h:Id | //h:PatRelHCP//h:Dept/h:AdditionalId | //h:PatRelHCP//h:Inst/h:Name | //h:PatRelHCP//h:MedSpeciality | //h:PatRelHCP//h:Inst/h:Id | //h:PatRelHCP/h:StartDateTime | //h:PatRelHCP/h:EndDateTime | //h:PatRelHCP//h:Address))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(//h:PatRelHCP//h:HCProf/h:Id | //h:PatRelHCP//h:HCProf/h:AdditionalId | //h:PatRelHCP//h:HCPerson/h:Id | //h:PatRelHCP//h:HCPerson/h:AdditionalId | //h:PatRelHCP//h:Dept/h:Id | //h:PatRelHCP//h:Dept/h:AdditionalId | //h:PatRelHCP//h:Inst/h:Name | //h:PatRelHCP//h:MedSpeciality | //h:PatRelHCP//h:Inst/h:Id | //h:PatRelHCP/h:StartDateTime | //h:PatRelHCP/h:EndDateTime | //h:PatRelHCP//h:Address))+1}">
			<xsl:if test="h:Type/@DN">
				<span class="strong">
					<xsl:value-of select="h:Type/@DN"/>
				</span>&#160;
			</xsl:if>
			<xsl:value-of select="h:Name"/>&#160;
		</td>
		<td colspan="{(($std-col)-3)*number(not(//h:PatRelHCP//h:Inst/h:Name | //h:PatRelHCP//h:MedSpeciality | //h:PatRelHCP//h:Inst/h:Id | //h:PatRelHCP/h:StartDateTime | //h:PatRelHCP/h:EndDateTime | //h:PatRelHCP//h:Address))+1}">
			<xsl:if test="h:TypeId/@V">
				<span class="strong">
					<xsl:value-of select="h:TypeId/@V"/>:</span>&#160;
			</xsl:if>
			<xsl:value-of select="h:Id"/>&#160;
		</td>
	</xsl:template>
	<xsl:template match="h:Address" mode="full">
		<xsl:if test="h:Type and not(h:Type/@V='XYZ')">
			<span class="strong">
				<xsl:for-each select="h:Type">
					<xsl:call-template name="k-3401"/>:&#160;
				</xsl:for-each>
			</span>
		</xsl:if>
		<xsl:if test="h:StreetAdr">
			<xsl:value-of select="h:StreetAdr"/>
		</xsl:if>
		<xsl:if test="h:PostalCode or h:City">
			<xsl:if test="h:StreetAdr">,&#160;</xsl:if>
			<xsl:value-of select="h:PostalCode"/>&#160;<xsl:value-of select="h:City"/>
		</xsl:if>
		<xsl:if test="h:CityDistr">&#160;,<xsl:for-each select="h:CityDistr">
				<xsl:call-template name="k-3403"/>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="h:County">&#160;,<xsl:for-each select="h:County">
				<xsl:call-template name="k-3402"/>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="h:Country">&#160;,<xsl:for-each select="h:Country">
				<xsl:call-template name="k-9043"/>
			</xsl:for-each>
		</xsl:if>
		<xsl:for-each select="h:TeleAddress">
			<xsl:call-template name="h:TeleAddress"/>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av vedllegg -->
	<xsl:template match="h:RefDoc">
		<xsl:param name="col"/>
		<xsl:if test="h:MsgType or h:Id or h:IssueDate or h:MimeType or h:Compression">
			<tr>
				<xsl:if test="h:MsgType">
					<th>Type</th>
					<td width="{((($col)-2)*number(not(h:Id | h:IssueDate | h:MimeType | h:Compression))+1)*$std-td}px" colspan="{(($col)-2)*number(not(h:Id | h:IssueDate | h:MimeType | h:Compression))+1}">
						<xsl:for-each select="h:MsgType">
							<xsl:call-template name="k-8114"/>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="h:Id">
					<th>Id</th>
					<td width="{((($col)-2-count(h:MsgType)*2)*number(not(h:IssueDate | h:MimeType | h:Compression))+1)*$std-td}px" colspan="{(($col)-2-count(h:MsgType)*2)*number(not(h:IssueDate | h:MimeType | h:Compression))+1}">
						<xsl:value-of select="h:Id"/>
					</td>
				</xsl:if>
				<xsl:if test="h:IssueDate">
					<th>Utstedt-dato</th>
					<td width="{((($col)-2-count(h:MsgType | h:Id)*2)*number(not(h:MimeType | h:Compression))+1)*$std-td}px" colspan="{(($col)-2-count(h:MsgType | h:Id)*2)*number(not(h:MimeType | h:Compression))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="h:IssueDate/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="h:MimeType">
					<th>Mimetype</th>
					<td width="{((($col)-2-count(h:MsgType | h:Id | h:IssueDate)*2)*number(not(h:Compression))+1)*$std-td}px" colspan="{(($col)-2-count(h:MsgType | h:Id | h:IssueDate)*2)*number(not(h:Compression))+1}">
						<xsl:value-of select="h:MimeType"/>
					</td>
				</xsl:if>
				<xsl:if test="h:Compression">
					<th>Komprimering</th>
					<td colspan="{($col)-1-count(h:MsgType | h:Id | h:IssueDate | h:MimeType)*2}">
						<xsl:for-each select="h:Compression">
							<xsl:call-template name="k-1204"/>
						</xsl:for-each>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="h:Description">
			<tr>
				<th>Beskrivelse</th>
				<td colspan="{($col)-1}">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="h:Description"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="h:Content or h:FileReference">
			<xsl:choose>
				<xsl:when test="contains(h:MimeType,'image')">
					<tr>
						<th>Bilde</th>
						<xsl:choose>
							<xsl:when test="h:FileReference">
								<td colspan="{($col)-1}">
									<img>
										<xsl:attribute name="src"><xsl:value-of select="h:FileReference"/></xsl:attribute>
										<xsl:attribute name="alt">Bilde fra ekstern URL</xsl:attribute>
									</img>
								</td>
							</xsl:when>
							<xsl:when test="h:Content">
								<td colspan="{($col)-1}">
									<xsl:choose>
										<xsl:when test="h:Content/base:Base64Container">
											<img>
												<xsl:attribute name="src"><xsl:value-of select="concat('data:',h:MimeType,';base64,',h:Content/base:Base64Container)"/></xsl:attribute>
												<xsl:attribute name="alt">Bilde vedlagt som base64-kode</xsl:attribute>
											</img>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="h:Content"/>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:when>
						</xsl:choose>
					</tr>
				</xsl:when>
				<xsl:when test="contains(h:MimeType,'pdf')">
					<tr>
						<th>pdf</th>
						<xsl:choose>
							<xsl:when test="h:FileReference">
								<td colspan="{($col)-1}">
									<object>
										<xsl:attribute name="data"><xsl:value-of select="concat(h:FileReference,'&#35;view&#61;FitH&#38;toolbar&#61;1')"/></xsl:attribute>
										<xsl:attribute name="type">application/pdf</xsl:attribute>
										<xsl:attribute name="width">100%</xsl:attribute>
										<xsl:attribute name="height">500px</xsl:attribute>
									</object>
								</td>
							</xsl:when>
							<xsl:when test="h:Content">
								<td colspan="{($col)-1}">
									<xsl:choose>
										<xsl:when test="h:Content/base:Base64Container">
											<object>
												<xsl:attribute name="data"><xsl:value-of select="concat('data:application/pdf;base64,',h:Content/base:Base64Container)"/></xsl:attribute>
												<xsl:attribute name="type">application/pdf</xsl:attribute>
												<xsl:attribute name="width">100%</xsl:attribute>
												<xsl:attribute name="height">500px</xsl:attribute>
											</object>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="h:Content"/>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:when>
						</xsl:choose>
					</tr>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="h:Content">
							<xsl:value-of select="h:Content"/>
						</xsl:when>
						<xsl:when test="h:FileReference">
							<xsl:value-of select="h:FileReference"/>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
