<?xml version="1.0" encoding="utf-8"?>
	<!-- Endringslogg
    - 18.05.17: v3.1.2 - Endret fra Rekvirent til Mottaker og Tjenesteyter til Avsender under "Helsetjenesteenheter"
								Endret logikk i visning av  Type opprinnelig visning. Tar nå tekst som er med i dis:MsgDescr, istedet for @V som ikke er med uansett siden det ikke er tillatt
								Fjernet visning av henvisningsdiagnose i epikrise-diagnosevisning. Flyttet den til feltet "Opprinnelig henvisning"
								Endret rekkefølgen på visning av "Helsetjenesteenheter"
	- 27.03.17: v3.1.1: Ny parameter for "visningStil. Ny stil "Smooth".
	- 25.10.16: v3.1.0: La til visningsversjonnr
	- 12.05.16: Komplettering av Helsetjenesteenheter-tabellen
	- 05.11.15: Innføring av felles kodeverksfil
	- 01.04.12: Ny grafisk layout
	- 01.12.10: Import av felles CSS-fil
	- 07.01.08: Første versjon
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
	<!-- Om
	- Inngår i Hdirs visningsfiler versjon 2.0
	- Laget i XMLSpy v2016 (http://www.altova.com) av Jan Sigurd Dragsjø (nhn.no)
	-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:dis="http://www.kith.no/xmlstds/epikrise/2006-09-23" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:base="http://www.kith.no/xmlstds/base64container" 
	exclude-result-prefixes="dis xhtml base">
	
	<!-- Import. Stien tilrettelegger for katalogstruktur med en meldings-katalog med versjons-kataloger inni. Sti må endres om slik struktur ikke benyttes -->
	<xsl:import href="../../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../../felleskomponenter/kodeverk.xsl"/>
	<xsl:import href="../../felleskomponenter/visningstil.xsl"/>

	<!-- Variabel for standard antall kolonner i tabellene-->
	<xsl:variable name="std-col" select="8"/>
	<xsl:variable name="std-td" select="200"/>
	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'epikrise1.1 - v3.1.2 '"/>
	<!-- Variabler for beregning av colspan i legemiddel-tabellen -->
	<xsl:variable name="med-stat-col" select="(($std-col)-2)*number(not(//dis:Medication/dis:UnitDose | //dis:Medication/dis:QuantitySupplied | //dis:Medication/dis:DosageText | //dis:Medication/dis:IntendedDuration | //dis:Medication/dis:Comment | //dis:InfItem[dis:Medication]/dis:StartDateTime | //dis:InfItem[dis:Medication]/dis:EndDateTime | //dis:InfItem[dis:Medication]/dis:OrgDate))+1"/>
	<xsl:variable name="med-unit-col" select="(($std-col)-3)*number(not(//dis:Medication/dis:DosageText | //dis:Medication/dis:IntendedDuration | //dis:Medication/dis:Comment | //dis:InfItem[dis:Medication]/dis:StartDateTime | //dis:InfItem[dis:Medication]/dis:EndDateTime | //dis:InfItem[dis:Medication]/dis:OrgDate))+1"/>
	<xsl:variable name="med-text-col" select="(($std-col)-3-number(boolean(//dis:Medication/dis:UnitDose | //dis:Medication/dis:QuantitySupplied)))*number(not(//dis:Medication/dis:Comment | //dis:InfItem[dis:Medication]/dis:StartDateTime | //dis:InfItem[dis:Medication]/dis:EndDateTime | //dis:InfItem[dis:Medication]/dis:OrgDate))+1"/>
	<xsl:variable name="med-com-col" select="(($std-col)-3-number(boolean(//dis:Medication/dis:UnitDose | //dis:Medication/dis:QuantitySupplied | //dis:Medication/dis:DosageText | //dis:Medication/dis:IntendedDuration)))*number(not(//dis:InfItem[dis:Medication]/dis:StartDateTime | //dis:InfItem[dis:Medication]/dis:EndDateTime | //dis:InfItem[dis:Medication]/dis:OrgDate))+1"/>
	<xsl:variable name="med-sdate-col" select="(($std-col)-3-number(boolean(//dis:Medication/dis:UnitDose | //dis:Medication/dis:QuantitySupplied))-number(boolean(//dis:Medication/dis:DosageText | //dis:Medication/dis:IntendedDuration))-number(boolean(//dis:Medication/dis:Comment)))*number(not(//dis:InfItem[dis:Medication]/dis:EndDateTime | //dis:InfItem[dis:Medication]/dis:OrgDate))+1"/>
	<xsl:variable name="med-edate-col" select="(($std-col)-3-number(boolean(//dis:Medication/dis:UnitDose | //dis:Medication/dis:QuantitySupplied))-number(boolean(//dis:Medication/dis:DosageText | //dis:Medication/dis:IntendedDuration))-number(boolean(//dis:Medication/dis:Comment))-number(boolean(//dis:InfItem[dis:Medication]/dis:StartDateTime)))*number(not(//dis:InfItem[dis:Medication]/dis:OrgDate))+1"/>
	<xsl:variable name="med-odate-col" select="(($std-col)-2-number(boolean(//dis:Medication/dis:UnitDose | //dis:Medication/dis:QuantitySupplied))-number(boolean(//dis:Medication/dis:DosageText | //dis:Medication/dis:IntendedDuration))-number(boolean(//dis:Medication/dis:Comment))-number(boolean(//dis:InfItem[dis:Medication]/dis:StartDateTime))-number(boolean(//dis:InfItem[dis:Medication]/dis:EndDateTime)))"/>
	<!-- Variabler for beregning av colspan i resultat-tabellen -->
	<xsl:variable name="res-res-col" select="(($std-col)-2)*number(not(//dis:ResultItem/dis:DevResultInd | //dis:ResultItem/dis:InvDate | //dis:InfItem[dis:ResultItem]/dis:StartDateTime | //dis:InfItem[dis:ResultItem]/dis:EndDateTime | //dis:InfItem[dis:ResultItem]/dis:OrgDate))+1"/>
	<xsl:variable name="res-dev-col" select="(($std-col)-3)*number(not(//dis:ResultItem/dis:InvDate | //dis:InfItem[dis:ResultItem]/dis:StartDateTime | //dis:InfItem[dis:ResultItem]/dis:EndDateTime | //dis:InfItem[dis:ResultItem]/dis:OrgDate))+1"/>
	<xsl:variable name="res-idate-col" select="(($std-col)-3-number(boolean(//dis:ResultItem/dis:DevResultInd)))*number(not(//dis:InfItem[dis:ResultItem]/dis:StartDateTime | //dis:InfItem[dis:ResultItem]/dis:EndDateTime | //dis:InfItem[dis:ResultItem]/dis:OrgDate))+1"/>
	<xsl:variable name="res-sdate-col" select="(($std-col)-3-number(boolean(//dis:ResultItem/dis:DevResultInd))-number(boolean(//dis:ResultItem/dis:InvDate)))*number(not(//dis:InfItem[dis:ResultItem]/dis:EndDateTime | //dis:InfItem[dis:ResultItem]/dis:OrgDate))+1"/>
	<xsl:variable name="res-edate-col" select="(($std-col)-3-number(boolean(//dis:ResultItem/dis:DevResultInd))-number(boolean(//dis:ResultItem/dis:InvDate))-number(boolean(//dis:InfItem[dis:ResultItem]/dis:StartDateTime)))*number(not(//dis:InfItem[dis:ResultItem]/dis:OrgDate))+1"/>
	<xsl:variable name="res-odate-col" select="(($std-col)-2-number(boolean(//dis:ResultItem/dis:DevResultInd))-number(boolean(//dis:ResultItem/dis:InvDate))-number(boolean(//dis:InfItem[dis:ResultItem]/dis:StartDateTime))-number(boolean(//dis:InfItem[dis:ResultItem]/dis:EndDateTime)))"/>
	<!-- Variabler for beregning av colspan i hendelser-tabellen -->
	<xsl:variable name="event-type-col" select="(($std-col)-1)*number(not(//dis:Event/dis:EventLocation | //dis:Event/dis:ReportedEvent | //dis:Event/dis:ExpDuration | //dis:Event/dis:AdmOutcome | //dis:Event/dis:Priority | //dis:Event/dis:AssRequest))+1"/>
	<xsl:variable name="event-place-col" select="(($std-col)-2)*number(not(//dis:Event/dis:ReportedEvent | //dis:Event/dis:ExpDuration | //dis:Event/dis:AdmOutcome | //dis:Event/dis:Priority | //dis:Event/dis:AssRequest))+1"/>
	<xsl:variable name="event-time-col" select="(($std-col)-2-number(boolean(//dis:Event/dis:EventLocation)))*number(not(//dis:Event/dis:AdmOutcome | //dis:Event/dis:Priority | //dis:Event/dis:AssRequest))+1"/>
	<xsl:variable name="event-out-col" select="(($std-col)-2-number(boolean(//dis:Event/dis:EventLocation))-number(boolean(//dis:Event/dis:ReportedEvent | //dis:Event/dis:ExpDuration)))*number(not(//dis:Event/dis:Priority | //dis:Event/dis:AssRequest))+1"/>
	<xsl:variable name="event-pri-col" select="(($std-col)-2-number(boolean(//dis:Event/dis:EventLocation))-number(boolean(//dis:Event/dis:ReportedEvent | //dis:Event/dis:ExpDuration))-number(boolean(//dis:Event/dis:AdmOutcome)))*number(not(//dis:Event/dis:AssRequest))+1"/>
	<xsl:variable name="event-ass-col" select="(($std-col)-1-number(boolean(//dis:Event/dis:EventLocation))-number(boolean(//dis:Event/dis:ReportedEvent | //dis:Event/dis:ExpDuration))-number(boolean(//dis:Event/dis:AdmOutcome))-number(boolean(//dis:Event/dis:Priority)))"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>Epikrise</title>
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
	<xsl:template match="dis:Message">
		<xsl:for-each select="dis:ServRprt">
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
						<xsl:apply-templates select="dis:ServProvider" mode="hode"/>
					</div>
				</div>
				<xsl:choose>
					<xsl:when test="dis:Patient">
						<div class="No-line-headerContent">
							<div class="No-line-caption">Pasient&#160;</div>
							<div class="No-line-content">
								<xsl:apply-templates select="dis:Patient" mode="hode"/>
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
						<xsl:apply-templates select="dis:Requester" mode="hode"/>
					</div>
				</div>
				<xsl:choose>
					<xsl:when test="dis:CopyDest">
						<div class="No-line-headerContent">
							<div class="No-line-caption">Kopimottaker&#160;</div>
							<div class="No-line-content">
								<xsl:apply-templates select="dis:CopyDest" mode="hode"/>
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
	<xsl:template match="dis:Requester" mode="hode">
		<xsl:apply-templates mode="hode" select="dis:HCP"/>
	</xsl:template>
	<xsl:template match="dis:ServProvider" mode="hode">
		<xsl:apply-templates mode="hode" select="dis:HCP"/>
	</xsl:template>
	<xsl:template match="dis:Patient" mode="hode">
		<div>
			<xsl:value-of select="dis:Name"/>&#160;
			<span class="strong">
				<xsl:for-each select="dis:TypeOffId">
					<xsl:call-template name="k-8116"/>
				</xsl:for-each>:&#160;</span>
				<xsl:value-of select="dis:OffId"/>&#160;
		</div>
		<xsl:if test="dis:DateOfDeath">
			<div>
				<span class="strong">Dødsdato:&#160;</span>
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="dis:DateOfDeath/@V"/>
				</xsl:call-template>
			</div>
		</xsl:if>
		<xsl:apply-templates mode="hode" select="dis:Address"/>
	</xsl:template>
	<xsl:template match="dis:HCPerson" mode="hode">
		<div>
			<xsl:value-of select="dis:Name"/>
			<div class="NoPrint">,</div>&#160;</div>
	</xsl:template>
	<xsl:template match="dis:HCP" mode="hode">
		<xsl:apply-templates mode="hode" select="dis:Inst"/>
		<xsl:apply-templates mode="hode" select="dis:HCProf"/>
		<xsl:apply-templates mode="hode" select="dis:Address"/>
	</xsl:template>
	<xsl:template match="dis:Inst" mode="hode">
		<xsl:apply-templates mode="hode" select="dis:HCPerson"/>
		<div>
			<xsl:value-of select="dis:Name"/>
		</div>
		<xsl:for-each select="dis:Dept">
			<div>
				<div class="NoPrint">-&#160;</div>
				<xsl:value-of select="dis:Name"/>&#160;</div>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="dis:HCProf" mode="hode">
		<div>
			<xsl:for-each select="dis:Type">
				<xsl:call-template name="k-9060"/>
			</xsl:for-each>&#160;<xsl:value-of select="dis:Name"/>
		</div>
	</xsl:template>
	<xsl:template match="dis:CopyDest" mode="hode">
		<xsl:apply-templates mode="hode" select="dis:HCP"/>
	</xsl:template>
	<xsl:template match="dis:Address" mode="hode">
		<xsl:if test="dis:Type and (dis:StreetAdr or dis:PostalCode or dis:City or dis:CityDistr)">
			<div class="NoPrint">&#160;<b>
					<xsl:for-each select="dis:Type">
						<xsl:call-template name="k-3401"/>
					</xsl:for-each>:&#160;</b>
			</div>
		</xsl:if>
		<xsl:if test="dis:StreetAdr">
			<div>
				<xsl:value-of select="dis:StreetAdr"/>
			</div>
		</xsl:if>
		<xsl:if test="dis:PostalCode or dis:City">
			<xsl:if test="dis:StreetAdr">
				<div class="NoPrint">,</div>
			</xsl:if>
			<div>
				<xsl:value-of select="dis:PostalCode"/>&#160;<xsl:value-of select="dis:City"/>
			</div>
		</xsl:if>
		<xsl:for-each select="dis:CityDistr">
			<div class="NoPrint">,</div>
			<div>
				<xsl:call-template name="k-3403"/>
			</div>
		</xsl:for-each>
		<xsl:for-each select="dis:County">
			<div class="NoPrint">,</div>
			<div>
				<xsl:call-template name="k-3402"/>
			</div>
		</xsl:for-each>
		<xsl:for-each select="dis:Country">
			<div class="NoPrint">,</div>
			<div>
				<xsl:call-template name="k-9043"/>
			</div>
		</xsl:for-each>
		<xsl:for-each select="dis:TeleAddress">
			<div class="NoPrint">&#160;</div>
			<xsl:apply-templates mode="hode" select="."/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="dis:TeleAddress" mode="hode">
		<div>
			<span class="strong">
				<xsl:choose>
					<xsl:when test="starts-with(@V, 'tel:') or starts-with(@V, 'callto:')">Telefon</xsl:when>
					<xsl:when test="starts-with(@V, 'fax:')">Faks</xsl:when>
					<xsl:when test="starts-with(@V, 'mailto:')">e-post</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring-before(@V, ':')"/>
					</xsl:otherwise>
				</xsl:choose>
			</span>&#160;<xsl:value-of select="substring-after(@V, ':')"/>&#160;
		</div>
	</xsl:template>
	<!-- Hoveddokumentet -->
	<xsl:template name="ResultBody">
		<xsl:variable name="position" select="position()"/>
		<xsl:variable name="color">
			<xsl:choose>
				<xsl:when test="dis:ServType[@V='M' or @V='C' or @V='O']">red</xsl:when>
				<xsl:otherwise>black</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div class="{$stil}">
			<xsl:call-template name="FellesMeny">
				<xsl:with-param name="position" select="position()"/>
			</xsl:call-template>
			<!-- Overskrift og tabell for epikrisen -->
			<h1>
				<xsl:choose>
					<xsl:when test="dis:MsgDescr and string-length(dis:MsgDescr) &gt; 0">
						<xsl:value-of select="dis:MsgDescr"/>
					</xsl:when>
					<xsl:otherwise>Epikrise</xsl:otherwise>
				</xsl:choose>
				<xsl:for-each select="dis:ServType[@V!='N']">&#160;-
					<font color="{$color}"><xsl:call-template name="k-7309"/></font>
				</xsl:for-each>
				<xsl:for-each select="dis:Status">&#160;-&#160;<xsl:call-template name="k-7306"/>
				</xsl:for-each>
			</h1>
			<table>
				<tbody>
					<xsl:apply-templates select="."/>
				</tbody>
			</table>
			<!-- Overskrift og tabell for Diagnoser -->
			<xsl:if test="//dis:InfItem[dis:Type/@V='H' or dis:Type/@V='B'] or //dis:DiagComment ">
				<xsl:variable name="id1">
					<xsl:value-of select="concat('Diagnosis',$position)"/>
				</xsl:variable>
				<h2 id="{$id1}">Diagnoser</h2>
				<table>
					<tbody>
						<xsl:for-each select="//dis:InfItem[dis:Type/@V='H']">
							<xsl:apply-templates/>
						</xsl:for-each>
						<xsl:for-each select="//dis:InfItem[dis:Type/@V='B']">
							<xsl:apply-templates/>
						</xsl:for-each>
						<!-- Dette gjelder for henvisningsgrunn
						<xsl:apply-templates select="//dis:Diagnosis"/>
						<xsl:apply-templates select="//dis:ReasonAsText[dis:Heading/@V='DIAG']"/>
						-->
						<xsl:apply-templates select="//dis:DiagComment"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for CAVE og NB-opplysninger -->
			<xsl:if test="//dis:InfItem[dis:Type/@V='CAVE' or dis:Type/@V='NB']">
				<xsl:variable name="id2">
					<xsl:value-of select="concat('CAVE',$position)"/>
				</xsl:variable>
				<h2 id="{$id2}">
					<xsl:if test="//dis:InfItem[dis:Type/@V='CAVE']">CAVE</xsl:if>
					<xsl:if test="//dis:InfItem[dis:Type/@V='CAVE'] and //dis:InfItem[dis:Type/@V='NB']">&#160;og&#160;</xsl:if>
					<xsl:if test="//dis:InfItem[dis:Type/@V='NB']">NB-opplysninger</xsl:if>
				</h2>
				<table>
					<tbody>
						<xsl:for-each select="//dis:InfItem[dis:Type/@V='CAVE']">
							<xsl:apply-templates/>
						</xsl:for-each>
						<xsl:for-each select="//dis:InfItem[dis:Type/@V='NB']">
							<xsl:apply-templates/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Årsak til innleggelse -->
			<xsl:if test="//dis:Comment[dis:Heading/@V='AI'] or //dis:Comment[dis:Heading/@V='ÅI']">
				<xsl:variable name="id3">
					<xsl:value-of select="concat('AI',$position)"/>
				</xsl:variable>
				<h2 id="{$id3}">Årsak&#160;til&#160;innleggelse</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="//dis:Comment[dis:Heading/@V='AI']"/>
						<xsl:apply-templates select="//dis:Comment[dis:Heading/@V='ÅI']"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Årsak til henvisning -->
			<xsl:if test="//dis:Comment[dis:Heading/@V='AH']">
				<xsl:variable name="id4">
					<xsl:value-of select="concat('AH',$position)"/>
				</xsl:variable>
				<h2 id="{$id4}">Årsak&#160;til&#160;henvisning</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="//dis:Comment[dis:Heading/@V='AH']"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Kliniske opplysninger -->
			<xsl:if test="//dis:InfItem[dis:Type/@V='OPPL']">
				<xsl:variable name="id50">
					<xsl:value-of select="concat('OPPL',$position)"/>
				</xsl:variable>
				<h2 id="{$id50}">Kliniske&#160;opplysninger</h2>
				<table>
					<tbody>
						<xsl:for-each select="//dis:InfItem[dis:Type/@V='OPPL']">
							<xsl:apply-templates/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Sykehistorie -->
			<xsl:if test="//dis:Comment[dis:Heading/@V='TS'] or //dis:InfItem[dis:Type/@V='ANAM']">
				<xsl:variable name="id5">
					<xsl:value-of select="concat('TS',$position)"/>
				</xsl:variable>
				<h2 id="{$id5}">Sykehistorie</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="//dis:Comment[dis:Heading/@V='TS']"/>
						<xsl:for-each select="//dis:InfItem[dis:Type/@V='ANAM']">
							<xsl:apply-templates/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Vurdering -->
			<xsl:if test="//dis:Comment[dis:Heading/@V='VU']">
				<xsl:variable name="id6">
					<xsl:value-of select="concat('VU',$position)"/>
				</xsl:variable>
				<h2 id="{$id6}">Vurdering</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="//dis:Comment[dis:Heading/@V='VU']"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Funn/undersøkelsesresultat -->
			<xsl:if test="//dis:Comment[dis:Heading/@V='FU' or dis:Heading/@V='LR'] or //dis:InfItem[dis:Type/@V='FUNN']">
				<xsl:variable name="id7">
					<xsl:value-of select="concat('FU',$position)"/>
				</xsl:variable>
				<h2 id="{$id7}">Funn/undersøkelsesresultat</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="//dis:Comment[dis:Heading/@V='FU']"/>
						<xsl:apply-templates select="//dis:Comment[dis:Heading/@V='LR']"/>
						<xsl:for-each select="//dis:InfItem[dis:Type/@V='FUNN']/dis:Observation">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
						<xsl:for-each select="//dis:ResultItem">
							<xsl:if test="position()=1">
								<tr>
									<th>Undersøkelse</th>
									<th colspan="{$res-res-col}">Funn/resultat</th>
									<xsl:if test="//dis:ResultItem/dis:DevResultInd">
										<th colspan="{$res-dev-col}">Avviksmarkør</th>
									</xsl:if>
									<xsl:if test="//dis:ResultItem/dis:InvDate">
										<th colspan="{$res-idate-col}">Tidspunkt&#160;for&#160;undersøkelsen</th>
									</xsl:if>
									<xsl:if test="//dis:InfItem[dis:ResultItem]/dis:StartDateTime">
										<th colspan="{$res-sdate-col}">Starttidspunkt</th>
									</xsl:if>
									<xsl:if test="//dis:InfItem[dis:ResultItem]/dis:EndDateTime">
										<th colspan="{$res-edate-col}">Sluttidspunkt</th>
									</xsl:if>
									<xsl:if test="//dis:InfItem[dis:ResultItem]/dis:OrgDate">
										<th colspan="{$res-odate-col}">Tidspunkt&#160;for&#160;opprinnelse</th>
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
			<!-- Overskrift og tabell for Forløp og behandling -->
			<xsl:if test="//dis:Comment[dis:Heading/@V='FO']">
				<xsl:variable name="id8">
					<xsl:value-of select="concat('FO',$position)"/>
				</xsl:variable>
				<h2 id="{$id8}">Forløp&#160;og&#160;behandling</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="//dis:Comment[dis:Heading/@V='FO']"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Medisinering -->
			<xsl:if test="//dis:Comment[dis:Heading/@V='ME'] or //dis:InfItem[dis:Type/@V='MEDB']">
				<xsl:variable name="id9">
					<xsl:value-of select="concat('ME',$position)"/>
				</xsl:variable>
				<h2 id="{$id9}">Medisinering</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="//dis:Comment[dis:Heading/@V='ME']"/>
						<xsl:for-each select="//dis:InfItem[dis:Type/@V='MEDB']/dis:Observation | //dis:InfItem[dis:Type/@V='MEDB']/dis:ResultItem">
							<xsl:apply-templates select="."/>
						</xsl:for-each>
						<xsl:for-each select="//dis:Medication">
							<xsl:if test="position()=1">
								<tr>
									<th>Legemiddel</th>
									<th colspan="{$med-stat-col}">Status</th>
									<xsl:if test="//dis:Medication/dis:UnitDose or //dis:Medication/dis:QuantitySupplied">
										<th colspan="{$med-unit-col}">Mengde</th>
									</xsl:if>
									<xsl:if test="//dis:Medication/dis:DosageText or //dis:Medication/dis:IntendedDuration">
										<th colspan="{$med-text-col}">
											<xsl:if test="//dis:Medication/dis:DosageText">Dosering</xsl:if>
											<xsl:if test="//dis:Medication/dis:DosageText and //dis:Medication/dis:IntendedDuration">/</xsl:if>
											<xsl:if test="//dis:Medication/dis:IntendedDuration">Varighet</xsl:if>
										</th>
									</xsl:if>
									<xsl:if test="//dis:Medication/dis:Comment">
										<th colspan="{$med-com-col}">Kommentar</th>
									</xsl:if>
									<xsl:if test="//dis:InfItem[dis:Medication]/dis:StartDateTime">
										<th colspan="{$med-sdate-col}">Starttidspunkt</th>
									</xsl:if>
									<xsl:if test="//dis:InfItem[dis:Medication]/dis:EndDateTime">
										<th colspan="{$med-edate-col}">Sluttidspunkt</th>
									</xsl:if>
									<xsl:if test="//dis:InfItem[dis:Medication]/dis:OrgDate">
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
			<!-- Overskrift og tabell for Funksjonsnivå/hjelpetiltak -->
			<xsl:if test="//dis:Comment[dis:Heading/@V='HJ']">
				<xsl:variable name="id10">
					<xsl:value-of select="concat('HJ',$position)"/>
				</xsl:variable>
				<h2 id="{$id10}">Funksjonsnivå/hjelpetiltak</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="//dis:Comment[dis:Heading/@V='HJ']"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Videre oppfølging -->
			<xsl:if test="//dis:Comment[dis:Heading/@V='OP']">
				<xsl:variable name="id11">
					<xsl:value-of select="concat('OP',$position)"/>
				</xsl:variable>
				<h2 id="{$id11}">Videre&#160;oppfølging</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="//dis:Comment[dis:Heading/@V='OP']"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Sykmelding -->
			<xsl:if test="//dis:Comment[dis:Heading/@V='SY'] or //dis:InfItem[dis:Type/@V='SYKM']">
				<xsl:variable name="id12">
					<xsl:value-of select="concat('SY',$position)"/>
				</xsl:variable>
				<h2 id="{$id12}">Sykmelding</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="//dis:Comment[dis:Heading/@V='SY']"/>
						<xsl:for-each select="//dis:InfItem[dis:Type/@V='SYKM']">
							<xsl:apply-templates/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Prosedyrer mv. -->
			<xsl:if test="//dis:InfItem[dis:Type/@V='OPIN' or dis:Type/@V='MPRS' or dis:Type/@V='PRS']">
				<xsl:variable name="id60">
					<xsl:value-of select="concat('PRS',$position)"/>
				</xsl:variable>
				<h2 id="{$id60}">Prosedyrer&#160;mv.</h2>
				<table>
					<tbody>
						<xsl:for-each select="//dis:InfItem[dis:Type/@V='OPIN' or dis:Type/@V='MPRS' or dis:Type/@V='PRS']">
							<xsl:apply-templates/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Andre kliniske opplysninger -->
			<xsl:if test="//dis:InfItem[dis:Type/@V='PROG' or dis:Type/@V='GBEH' or dis:Type/@V='GOPL' or dis:Type/@V='SYMP' or dis:Type/@V='TB' or dis:Type/@V='US' or dis:Type/@V='SM']">
				<xsl:variable name="id70">
					<xsl:value-of select="concat('PROG',$position)"/>
				</xsl:variable>
				<h2 id="{$id70}">Andre&#160;kliniske&#160;opplysninger</h2>
				<table>
					<tbody>
						<xsl:for-each select="//dis:InfItem[dis:Type/@V='PROG' or dis:Type/@V='GBEH' or dis:Type/@V='GOPL' or dis:Type/@V='SYMP' or dis:Type/@V='TB' or dis:Type/@V='US' or dis:Type/@V='SM']">
							<xsl:apply-templates/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Familie/sosialt -->
			<xsl:if test="//dis:Comment[dis:Heading/@V='FA']">
				<xsl:variable name="id13">
					<xsl:value-of select="concat('FA',$position)"/>
				</xsl:variable>
				<h2 id="{$id13}">Familie/sosialt</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="//dis:Comment[dis:Heading/@V='FA']"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Informasjon til pasient/pårørende -->
			<xsl:if test="//dis:Comment[dis:Heading/@V='IP']">
				<xsl:variable name="id14">
					<xsl:value-of select="concat('IP',$position)"/>
				</xsl:variable>
				<h2 id="{$id14}">Informasjon&#160;til&#160;pasient/pårørende</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="//dis:Comment[dis:Heading/@V='IP']"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Ubesvarte prøver -->
			<xsl:if test="//dis:Comment[dis:Heading/@V='UP']">
				<xsl:variable name="id15">
					<xsl:value-of select="concat('UP',$position)"/>
				</xsl:variable>
				<h2 id="{$id15}">Ubesvarte&#160;prøver</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="//dis:Comment[dis:Heading/@V='UP']"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Tilbakemelding (uspes.) -->
			<xsl:if test="//dis:Comment[dis:Heading/@V='TB'] or //dis:Comment[not(dis:Heading)]">
				<xsl:variable name="id16">
					<xsl:value-of select="concat('TB',$position)"/>
				</xsl:variable>
				<h2 id="{$id16}">Tilbakemelding&#160;(uspes.)</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="//dis:Comment[dis:Heading/@V='TB']"/>
						<xsl:apply-templates select="//dis:Comment[not(dis:Heading)]"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for øvrig pasientinformasjon -->
			<xsl:for-each select="dis:Patient">
				<xsl:if test="dis:BasisForHealthServices or dis:Sex or dis:DateOfBirth or dis:PatientPrecaution or dis:NeedTranslator or dis:CareSituation or dis:PatRelperson or dis:PatRelInst or dis:Consent or dis:AdditionalId">
					<xsl:variable name="id30">
						<xsl:value-of select="concat('Patient',$position)"/>
					</xsl:variable>
					<h2 id="{$id30}">Pasient</h2>
					<table>
						<tbody>
							<xsl:apply-templates select="."/>
						</tbody>
					</table>
				</xsl:if>
			</xsl:for-each>
			<!-- Overskrift og tabell for øvrig informasjon helsetjenesteenheter -->
			<xsl:variable name="id31">
				<xsl:value-of select="concat('HCP',$position)"/>
			</xsl:variable>
			<h2 id="{$id31}">Helsetjenesteenheter</h2>
			<table>
				<tbody>
					<!-- For Avsender -->
					<xsl:for-each select="dis:ServProvider">
						<xsl:apply-templates select=".">
							<xsl:with-param name="col" select="$std-col"/>
						</xsl:apply-templates>
					</xsl:for-each>
					<!-- For mottaker -->
					<xsl:for-each select="dis:Requester">
						<xsl:apply-templates select=".">
							<xsl:with-param name="col" select="$std-col"/>
						</xsl:apply-templates>
					</xsl:for-each>
					<!-- For kopimottaker -->
					<xsl:for-each select="dis:CopyDest">
						<xsl:apply-templates select=".">
							<xsl:with-param name="col" select="$std-col"/>
						</xsl:apply-templates>
					</xsl:for-each>
					<!-- For ansvarlig helsepersonell -->
					<xsl:for-each select=".//dis:RelServProvider">
						<xsl:apply-templates select=".">
							<xsl:with-param name="col" select="$std-col"/>
						</xsl:apply-templates>
					</xsl:for-each>
					<!-- For ansvarlig for opplysninger -->
					<xsl:for-each select=".//dis:Origin">
						<xsl:apply-templates select=".">
							<xsl:with-param name="col" select="$std-col"/>
						</xsl:apply-templates>
					</xsl:for-each>	
					<!-- For ansvarlig for noe informasjon -->
					<xsl:for-each select=".//dis:RelHCProvider">
						<xsl:apply-templates select=".">
							<xsl:with-param name="col" select="$std-col"/>
						</xsl:apply-templates>
					</xsl:for-each>	
					<!-- For pasientrelatert helsetjenesteenhet -->
					<xsl:for-each select=".//dis:PatRelHCP">
						<xsl:apply-templates select=".">
							<xsl:with-param name="col" select="$std-col"/>
						</xsl:apply-templates>
					</xsl:for-each>	
				</tbody>
			</table>
			<!-- Hendelse -->
			<xsl:if test="dis:Event">
				<xsl:variable name="id32">
					<xsl:value-of select="concat('Event',$position)"/>
				</xsl:variable>
				<h2 id="{$id32}">Hendelser</h2>
				<table>
					<tbody>
						<xsl:for-each select="//dis:Event">
							<xsl:if test="position()=1">
								<tr>
									<th colspan="{$event-type-col}">Type</th>
									<xsl:if test="..//dis:EventLocation">
										<th colspan="{$event-place-col}">Sted</th>
									</xsl:if>
									<xsl:if test="..//dis:ReportedEvent/dis:StartDateTime or ..//dis:ReportedEvent/dis:EndDateTime or ..//dis:ExpDuration">
										<th colspan="{$event-time-col}">Tidspunkt</th>
									</xsl:if>
									<xsl:if test="..//dis:AdmOutcome">
										<th colspan="{$event-out-col}">Ut&#160;til</th>
									</xsl:if>
									<xsl:if test="..//dis:Priority">
										<th colspan="{$event-pri-col}">Prioritet</th>
									</xsl:if>
									<xsl:if test="..//dis:AssRequest">
										<th colspan="{$event-ass-col}">Tilknyttet&#160;melding/dokument</th>
									</xsl:if>
								</tr>
							</xsl:if>
							<xsl:if test="position() &gt; 1 and not(local-name(..)=&quot;Event&quot;)">
								<tr><td colspan="{$std-col}"><hr/></td></tr>
							</xsl:if>
							<xsl:apply-templates select="."/>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for referert dokument -->
			<xsl:if test="dis:RefDoc">
				<xsl:variable name="id40">
					<xsl:value-of select="concat('RefDoc',$position)"/>
				</xsl:variable>
				<h2 id="{$id40}">Vedlegg</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="dis:RefDoc"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Opprinnelig henvisning -->
			<xsl:if test="dis:ServReq">
				<xsl:variable name="id41">
					<xsl:value-of select="concat('ServReq',$position)"/>
				</xsl:variable>
				<h2 id="{$id41}">Opprinnelig&#160;henvisning</h2>
				<table>
					<tbody>
						<xsl:apply-templates select="dis:ServReq"/>
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
								<xsl:with-param name="oppgittTid" select="../dis:GenDate/@V"/>
							</xsl:call-template>
						</td>
						<th>Meldingsid</th>
						<td><xsl:value-of select="../dis:MsgId"/></td>
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
					<xsl:if test="//dis:Diagnosis or //dis:DiagComment or //dis:ReasonAsText[dis:Heading/@V='DIAG'] or //dis:InfItem[dis:Type/@V='H' or dis:Type/@V='B']">
						<li>
							<xsl:variable name="temp1" select="concat('Diagnosis',$position)"/>
							<a href="#{$temp1}">Diagnoser</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:InfItem[dis:Type/@V='CAVE' or dis:Type/@V='NB']">
						<li>
							<xsl:variable name="temp2" select="concat('CAVE',$position)"/>
							<a href="#{$temp2}">
								<xsl:if test="//dis:InfItem[dis:Type/@V='CAVE']">CAVE</xsl:if>
								<xsl:if test="//dis:InfItem[dis:Type/@V='CAVE'] and //dis:InfItem[dis:Type/@V='NB']">&#160;og&#160;</xsl:if>
								<xsl:if test="//dis:InfItem[dis:Type/@V='NB']">NB-opplysninger</xsl:if>
							</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:Comment[dis:Heading/@V='AI'] or //dis:Comment[dis:Heading/@V='ÅI']">
						<li>
							<xsl:variable name="temp3" select="concat('AI',$position)"/>
							<a href="#{$temp3}">Årsak&#160;til&#160;innleggelse</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:Comment[dis:Heading/@V='AH']">
						<li>
							<xsl:variable name="temp4" select="concat('AH',$position)"/>
							<a href="#{$temp4}">Årsak&#160;til&#160;henvisning</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:InfItem[dis:Type/@V='OPPL']">
						<li>
							<xsl:variable name="temp50" select="concat('OPPL',$position)"/>
							<a href="#{$temp50}">Kliniske&#160;opplysninger</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:Comment[dis:Heading/@V='TS'] or //dis:InfItem[dis:Type/@V='ANAM']">
						<li>
							<xsl:variable name="temp5" select="concat('TS',$position)"/>
							<a href="#{$temp5}">Sykehistorie</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:Comment[dis:Heading/@V='VU']">
						<li>
							<xsl:variable name="temp6" select="concat('VU',$position)"/>
							<a href="#{$temp6}">Vurdering</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:Comment[dis:Heading/@V='FU' or dis:Heading/@V='LR'] or //dis:InfItem[dis:Type/@V='FUNN']">
						<li>
							<xsl:variable name="temp7" select="concat('FU',$position)"/>
							<a href="#{$temp7}">Funn&#160;og&#160;undersøkelsesresultater</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:Comment[dis:Heading/@V='FO']">
						<li>
							<xsl:variable name="temp8" select="concat('FO',$position)"/>
							<a href="#{$temp8}">Forløp&#160;og&#160;behandling</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:Comment[dis:Heading/@V='ME'] or //dis:InfItem[dis:Type/@V='MEDB']">
						<li>
							<xsl:variable name="temp9" select="concat('ME',$position)"/>
							<a href="#{$temp9}">Medisinering</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:Comment[dis:Heading/@V='HJ']">
						<li>
							<xsl:variable name="temp10" select="concat('HJ',$position)"/>
							<a href="#{$temp10}">Funksjonsnivå/hjelpetiltak</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:Comment[dis:Heading/@V='OP']">
						<li>
							<xsl:variable name="temp11" select="concat('OP',$position)"/>
							<a href="#{$temp11}">Videre&#160;oppfølging</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:Comment[dis:Heading/@V='SY'] or //dis:InfItem[dis:Type/@V='SYKM']">
						<li>
							<xsl:variable name="temp12" select="concat('SY',$position)"/>
							<a href="#{$temp12}">Sykmelding</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:InfItem[dis:Type/@V='OPIN' or dis:Type/@V='MPRS' or dis:Type/@V='PRS']">
						<li>
							<xsl:variable name="temp60" select="concat('PRS',$position)"/>
							<a href="#{$temp60}">Prosedyrer&#160;mv.</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:InfItem[dis:Type/@V='PROG' or dis:Type/@V='GBEH' or dis:Type/@V='GOPL' or dis:Type/@V='SYMP' or dis:Type/@V='TB' or dis:Type/@V='US' or dis:Type/@V='SM']">
						<li>
							<xsl:variable name="temp70" select="concat('PROG',$position)"/>
							<a href="#{$temp70}">Andre&#160;kliniske&#160;opplysninger</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:Comment[dis:Heading/@V='FA']">
						<li>
							<xsl:variable name="temp13" select="concat('FA',$position)"/>
							<a href="#{$temp13}">Familie/sosialt</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:Comment[dis:Heading/@V='IP']">
						<li>
							<xsl:variable name="temp14" select="concat('IP',$position)"/>
							<a href="#{$temp14}">Informasjon&#160;til&#160;pasient/pårørende</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:Comment[dis:Heading/@V='UP']">
						<li>
							<xsl:variable name="temp15" select="concat('UP',$position)"/>
							<a href="#{$temp15}">Ubesvarte&#160;prøver</a>
						</li>
					</xsl:if>
					<xsl:if test="//dis:Comment[dis:Heading/@V='TB']">
						<li>
							<xsl:variable name="temp16" select="concat('TB',$position)"/>
							<a href="#{$temp16}">Tilbakemelding&#160;(uspes.)</a>
						</li>
					</xsl:if>
					<xsl:for-each select="//dis:Patient">
						<xsl:if test="dis:Sex or dis:DateOfBirth or dis:PatientPrecaution or dis:PatientRelParty or dis:AdditionalId">
							<li>
								<xsl:variable name="temp30" select="concat('Patient',$position)"/>
								<a href="#{$temp30}">Pasient</a>
							</li>
						</xsl:if>
					</xsl:for-each>
					<xsl:if test="dis:ServProvider or dis:Requester or dis:CopyDest or .//dis:RelServProvider or .//dis:Origin or .//dis:RelHCProvider or .//dis:PatRelHCP">
						<li>
							<xsl:variable name="temp31" select="concat('HCP',$position)"/>
							<a href="#{$temp31}">Helsetjenesteenheter</a>
						</li>
					</xsl:if>
					<xsl:if test="dis:Event">
						<li>
							<xsl:variable name="temp32" select="concat('Event',$position)"/>
							<a href="#{$temp32}">Hendelser</a>
						</li>
					</xsl:if>
					<xsl:if test="dis:RefDoc">
						<li>
							<xsl:variable name="temp40" select="concat('RefDoc',$position)"/>
							<a href="#{$temp40}">Vedlegg</a>
						</li>
					</xsl:if>
					<xsl:if test="dis:ServReq">
						<li>
							<xsl:variable name="temp41" select="concat('ServReq',$position)"/>
							<a href="#{$temp41}">Opprinnelig&#160;henvisning</a>
						</li>
					</xsl:if>
				</ul>
			</div>
		</div>
	</xsl:template>
	<!-- Visning av Tilbakemelding -->
	<xsl:template match="dis:ServRprt">
		<xsl:if test="//dis:ReportedEvent/dis:StartDateTime or //dis:ReportedEvent/dis:EndDateTime">
			<tr>
				<xsl:for-each select="//dis:ReportedEvent">
					<xsl:if test="dis:StartDateTime and position()=1">
						<th>Innlagt</th>
						<td width="{((($std-col)-2)*number(not(dis:EndDateTime))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(dis:EndDateTime))+1}">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="dis:StartDateTime/@V"/>
							</xsl:call-template>
						</td>
					</xsl:if>
					<xsl:if test="dis:EndDateTime and position()=last()">
						<th>Utskrevet</th>
						<td colspan="{($std-col)-1-count(dis:StartDateTime)*2}">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="dis:EndDateTime/@V"/>
							</xsl:call-template>
						</td>
					</xsl:if>
				</xsl:for-each>
			</tr>
		</xsl:if>
		<xsl:if test="//dis:RelServProvider">
			<xsl:for-each select="//dis:RelServProvider//dis:HCProf">
				<xsl:if test="position()=1">
					<tr>
						<th>Ansvarlig</th>
						<td colspan="{($std-col)-1}">
							<xsl:for-each select="dis:Type">
								<xsl:call-template name="k-9060"/>&#160;
							</xsl:for-each>
							<xsl:value-of select="dis:Name"/>
						</td>
					</tr>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		<tr>
			<xsl:if test="dis:IssueDate">
				<th>Utstedt</th>
				<td width="{((($std-col)-2)*number(not(dis:Priority | dis:ApprDate | dis:Ack))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(dis:Priority | dis:ApprDate | dis:Ack))+1}">
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="dis:IssueDate/@V"/>
					</xsl:call-template>
				</td>
			</xsl:if>
			<xsl:if test="dis:Priority">
				<th>Hastegrad</th>
				<td width="{((($std-col)-2-count(dis:IssueDate)*2)*number(not(dis:ApprDate | dis:Ack))+1)*$std-td}px" colspan="{(($std-col)-2-count(dis:IssueDate)*2)*number(not(dis:ApprDate | dis:Ack))+1}">
					<xsl:for-each select="dis:Priority">
						<xsl:call-template name="k-7303"/>
					</xsl:for-each>
				</td>
			</xsl:if>
			<xsl:if test="dis:ApprDate">
				<th>Godkjent</th>
				<td width="{((($std-col)-2-count(dis:IssueDate | dis:Priority)*2)*number(not(dis:Ack))+1)*$std-td}px" colspan="{(($std-col)-2-count(dis:IssueDate | dis:Priority)*2)*number(not(dis:Ack))+1}">
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="dis:ApprDate/@V"/>
					</xsl:call-template>
				</td>
			</xsl:if>
			<xsl:if test="dis:Ack">
				<th>Meldingsbekreftelse</th>
				<td colspan="{($std-col)-1-count(dis:IssueDate | dis:Priority | dis:ApprDate)*2}">
					<xsl:for-each select="dis:Ack">
						<xsl:call-template name="k-7304"/>
					</xsl:for-each>
				</td>
			</xsl:if>
		</tr>
	</xsl:template>
	<!-- Visning av Henvisning -->
	<xsl:template match="dis:ServReq">
	   
		<xsl:variable name="color2">
			<xsl:choose>
				<xsl:when test="dis:ServType[@V='M' or @V='C' or @V='O']">red</xsl:when>
				<xsl:otherwise>black</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<tr>
			<xsl:if test="dis:MsgDescr">
				<th>Type</th>
				<td width="{((($std-col)-2)*number(not(dis:IssueDate | dis:ReceiptDate | dis:ReqComment))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(dis:IssueDate | dis:ReceiptDate | dis:ReqComment))+1}">
					<xsl:value-of select="child::*[local-name()='MsgDescr']"/> <!-- For versjon av epikrise hvor MsgDescr er kith:ST -->
					<xsl:for-each select="dis:ServType[@V!='N']">
						&#160;<font color="{$color2}"><xsl:call-template name="k-7309"/></font>
					</xsl:for-each>
				</td>
			</xsl:if>
			<xsl:if test="dis:IssueDate">
				<th>Utstedt</th>
				<td width="{((($std-col)-2-count(dis:MsgDescr)*2)*number(not(dis:ReceiptDate | dis:ReqComment))+1)*$std-td}px" colspan="{(($std-col)-2-count(dis:MsgDescr)*2)*number(not(dis:ReceiptDate | dis:ReqComment))+1}">
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="dis:IssueDate/@V"/>
					</xsl:call-template>
				</td>
			</xsl:if>
			<xsl:if test="dis:ReceiptDate">
				<th>Mottatt</th>
				<td width="{((($std-col)-2-count(dis:MsgDescr | dis:IssueDate)*2)*number(not(dis:ReqComment))+1)*$std-td}px" colspan="{(($std-col)-2-count(dis:MsgDescr | dis:IssueDate)*2)*number(not(dis:ReqComment))+1}">
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="dis:ReceiptDate/@V"/>
					</xsl:call-template>
				</td>
			</xsl:if>
			<xsl:if test="dis:ReqComment">
				<th>Kommentar</th>
				<td colspan="{($std-col)-1-count(dis:MsgDescr | dis:IssueDate | dis:ReceiptDate)*2}">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="dis:ReqComment"/>
					</xsl:call-template>
				</td>
			</xsl:if>
			
		</tr>
		<tr>
			<xsl:if test="//dis:Diagnosis or //dis:DiagComment or //dis:ReasonAsText[dis:Heading/@V='DIAG']">
				<xsl:choose>
					<xsl:when test="count(child::*[local-name()='Diagnosis'])>1">
						<th>Diagnoser</th>
						<td></td>
						<tr></tr> 
					</xsl:when>
					<xsl:otherwise>
						<th>Diagnose</th>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:for-each select="//dis:Diagnosis">
				<!-- 	<th>Diagnose:</th> -->
					<td colspan="2">
						<xsl:value-of select="dis:Concept/@V"/>&#160;
						<xsl:if test="contains(dis:Concept/@S, '7170')">(ICPC)&#160;</xsl:if>
						<xsl:if test="contains(dis:Concept/@S, '7110')">(ICD-10)&#160;</xsl:if>
						<xsl:if test="dis:Concept/@DN or dis:Concept/@OT">
							<xsl:for-each select="dis:Concept">
								<xsl:call-template name="k-dummy"/>
							</xsl:for-each>
					    </xsl:if>
						<xsl:for-each select="dis:Modifier">
							<xsl:if test="dis:Value/@DN or dis:Value/@OT">
								<xsl:for-each select="dis:Value">, 
									<xsl:call-template name="k-dummy"/>
								</xsl:for-each>
							</xsl:if>
						</xsl:for-each>
					</td>
					<tr></tr> 
				</xsl:for-each>
			</xsl:if>		
		
		<xsl:apply-templates select="dis:ReasonAsText"/>
		</tr>
		
	</xsl:template>
	<!-- Visning av Diagnose -->
	<xsl:template match="dis:Diagnosis | dis:DiagComment | dis:CodedDescr | dis:CodedComment">
	
		<xsl:variable name="HovedDiagnose">
			<xsl:choose>
				<xsl:when test="../../dis:Type/@V='H'">bold</xsl:when>
				<xsl:otherwise>normal</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<tr>
			<th style="font-weight:{$HovedDiagnose}">
				<xsl:value-of select="dis:Concept/@V"/>&#160;
				<xsl:if test="contains(dis:Concept/@S, '7170')">(ICPC)</xsl:if>
				<xsl:if test="contains(dis:Concept/@S, '7110')">(ICD-10)</xsl:if>
			</th>
			
			<td style="font-weight:{$HovedDiagnose}" width="{((($std-col)-2)*number(not(dis:Modifier))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(dis:Modifier))+1}">
				<xsl:if test="dis:Concept/@DN or dis:Concept/@OT">
					<xsl:for-each select="dis:Concept">
						<xsl:call-template name="k-dummy"/>
					</xsl:for-each>
				</xsl:if>
				<xsl:for-each select="dis:Modifier">
					<xsl:if test="dis:Value/@DN or dis:Value/@OT">
				    	<xsl:for-each select="dis:Value">, 
					        <xsl:call-template name="k-dummy"/>
					    </xsl:for-each>
					</xsl:if>
				</xsl:for-each>
			</td>
		</tr>
	</xsl:template>
	<!-- Visning av Begrunnelse for / kommentar til henvisningen -->
	<xsl:template match="dis:ReasonAsText | dis:Comment">
		<tr>
			<xsl:if test="local-name(.)=&quot;ReasonAsText&quot;">
				<th>
					<xsl:for-each select="dis:Heading">
						<xsl:call-template name="k-8231"/>
					</xsl:for-each>
					<xsl:if test="not(dis:Heading)">Begrunnelse&#160;(uspes.)</xsl:if>
				</th>
			</xsl:if>
			<td colspan="{($std-col)-1}">
				<xsl:for-each select="dis:TextResultValue">
					<div>
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
					</div>
				</xsl:for-each>
				<xsl:for-each select="dis:TextCode">
					<div>
						<xsl:choose>
							<xsl:when test="@DN"><xsl:value-of select="@DN"/>&#160;</xsl:when>
							<xsl:when test="@OT"><xsl:value-of select="@OT"/>&#160;</xsl:when>
							<xsl:when test="@V"><xsl:value-of select="@V"/>&#160;<xsl:choose>
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
	<!-- Visning av Annen klinisk opplysning -->
	<xsl:template match="dis:Observation">
		<xsl:if test="dis:Description or dis:Comment or ../dis:StartDateTime or ../dis:EndDateTime or ../dis:OrgDate">
			<tr>
				<td width="{((($std-col)-1)*number(not(../dis:StartDateTime | ../dis:EndDateTime | ../dis:OrgDate))+1)*$std-td}px" colspan="{(($std-col)-1)*number(not(../dis:StartDateTime | ../dis:EndDateTime | ../dis:OrgDate))+1}">
					<xsl:for-each select="dis:Description">
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
					<xsl:if test="dis:Comment">
						<div>
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="dis:Comment"/>
							</xsl:call-template>
						</div>
					</xsl:if>
				</td>
				<xsl:if test="../dis:StartDateTime or ../dis:EndDateTime or ../dis:OrgDate">
					<td colspan="{($std-col)-1}">
						<xsl:if test="../dis:StartDateTime">
							<div>Start:&#160;
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="../dis:StartDateTime/@V"/>
								</xsl:call-template>
							</div>
						</xsl:if>
						<xsl:if test="../dis:EndDateTime">
							<div>Slutt:&#160;
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="../dis:EndDateTime/@V"/>
								</xsl:call-template>
							</div>
						</xsl:if>
						<xsl:if test="../dis:OrgDate">
							<div>Opprinnelse:&#160;
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="../dis:OrgDate/@V"/>
								</xsl:call-template>
							</div>
						</xsl:if>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:apply-templates select="dis:CodedDescr"/>
	</xsl:template>
	<!-- Visning av Undersøkelsesresultat -->
	<xsl:template match="dis:ResultItem">
		<td>
			<xsl:for-each select="dis:ClinInv">
				<div>
					<xsl:for-each select="dis:Id">
						<xsl:call-template name="k-dummy"/>
					</xsl:for-each>
				</div>
				<xsl:for-each select="dis:Spec">
					<div>
						<span class="strong">Spesifisert:</span>&#160;
						<xsl:call-template name="k-dummy"/>
					</div>
				</xsl:for-each>
			</xsl:for-each>
		</td>
		<td width="{$res-res-col*$std-td}px" colspan="{$res-res-col}">
			<xsl:for-each select="dis:Interval">
				<xsl:if test="dis:Low"><b>Nedre:</b>&#160;<xsl:value-of select="dis:Low/@V"/><xsl:value-of select="dis:Low/@U"/>&#160;</xsl:if>
				<xsl:if test="dis:High"><b>Øvre:</b>&#160;<xsl:value-of select="dis:High/@V"/><xsl:value-of select="dis:High/@U"/>&#160;</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="dis:DateResult">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="dis:DateResultValue/@V"/>
				</xsl:call-template>
			</xsl:for-each>
			<xsl:for-each select="dis:NumResult">
				<xsl:for-each select="dis:ArithmeticComp">
					<xsl:call-template name="k-8239"/>&#160;
				</xsl:for-each>
				<xsl:value-of select="dis:NumResultValue/@V"/>&#160;<xsl:value-of select="dis:NumResultValue/@U"/>&#160;
				<xsl:for-each select="../dis:DevResultInd">
					<b><xsl:call-template name="k-8244"/></b>
				</xsl:for-each>
			</xsl:for-each>
			<xsl:for-each select="dis:TextResult/dis:Result">
				<xsl:if test="dis:TextResultValue">
					<div><xsl:call-template name="line-breaks"><xsl:with-param name="text" select="dis:TextResultValue"/></xsl:call-template></div>
				</xsl:if>
				<xsl:if test="dis:TextCode">
					<div>
						<xsl:call-template name="k-dummy"/>
					</div>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="dis:Comment">
				<div>
					<span class="strong">Kommentar:</span>&#160;<xsl:call-template name="line-breaks"><xsl:with-param name="text" select="dis:Comment"/></xsl:call-template>
				</div>
			</xsl:if>
		</td>
		<xsl:if test="//dis:ResultItem/dis:InvDate">
			<td width="{$res-idate-col*$std-td}px" colspan="{$res-idate-col}">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="dis:InvDate/@V"/>
				</xsl:call-template>
			</td>
		</xsl:if>
		<xsl:if test="//dis:InfItem[dis:ResultItem]/dis:StartDateTime">
			<td width="{$res-sdate-col*$std-td}px" colspan="{$res-sdate-col}">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../dis:StartDateTime/@V"/>
				</xsl:call-template>
			</td>
		</xsl:if>
		<xsl:if test="//dis:InfItem[dis:ResultItem]/dis:EndDateTime">
			<td width="{$res-edate-col*$std-td}px" colspan="{$res-edate-col}">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../dis:EndDateTime/@V"/>
				</xsl:call-template>
			</td>
		</xsl:if>
		<xsl:if test="//dis:InfItem[dis:ResultItem]/dis:OrgDate">
			<td colspan="{$res-odate-col}">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../dis:OrgDate/@V"/>
				</xsl:call-template>
			</td>
		</xsl:if>
	</xsl:template>
	<!-- Visning av Medikamentell behandling -->
	<xsl:template match="dis:Medication">
		<td>
			<xsl:for-each select="dis:DrugId">
				<xsl:call-template name="k-dummy"/>
			</xsl:for-each>
		</td>
		<td width="{$med-stat-col*$std-td}px" colspan="{$med-stat-col}">
			<xsl:for-each select="dis:Status">
				<xsl:call-template name="k-7307"/>&#160;
			</xsl:for-each>
		</td>
		<xsl:if test="//dis:Medication/dis:UnitDose or //dis:Medication/dis:QuantitySupplied">
			<td width="{$med-unit-col*$std-td}px" colspan="{$med-unit-col}">
				<xsl:if test="dis:UnitDose">
					<xsl:value-of select="dis:UnitDose/@V"/>&#160;<xsl:value-of select="dis:UnitDose/@U"/>
					<xsl:if test="dis:QuantitySupplied">&#160;x&#160;</xsl:if>
				</xsl:if>
				<xsl:if test="dis:QuantitySupplied">
					<xsl:value-of select="dis:QuantitySupplied/@V"/>&#160;<xsl:value-of select="dis:QuantitySupplied/@U"/>
				</xsl:if>&#160;
			</td>
		</xsl:if>
		<xsl:if test="//dis:Medication/dis:DosageText or //dis:Medication/dis:IntendedDuration">
			<td width="{$med-text-col*$std-td}px" colspan="{$med-text-col}">
				<xsl:if test="dis:DosageText">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="dis:DosageText"/>
					</xsl:call-template>
				</xsl:if>&#160;
				<xsl:if test="dis:IntendedDuration">&#160;/&#160;<xsl:value-of select="dis:IntendedDuration/@V"/>&#160;<xsl:value-of select="dis:IntendedDuration/@U"/></xsl:if>
				<xsl:if test="not(dis:DosageText) and not(dis:IntendedDuration)">&#160;</xsl:if>
			</td>
		</xsl:if>
		<xsl:if test="//dis:Medication/dis:Comment">
			<td width="{$med-com-col*$std-td}px" colspan="{$med-com-col}">
				<xsl:call-template name="line-breaks">
					<xsl:with-param name="text" select="dis:Comment"/>
				</xsl:call-template>
			</td>
		</xsl:if>
		<xsl:if test="//dis:InfItem[dis:Medication]/dis:StartDateTime">
			<td width="{$med-sdate-col*$std-td}px" colspan="{$med-sdate-col}">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../dis:StartDateTime/@V"/>
				</xsl:call-template>
			</td>
		</xsl:if>
		<xsl:if test="//dis:InfItem[dis:Medication]/dis:EndDateTime">
			<td width="{$med-edate-col*$std-td}px" colspan="{$med-edate-col}">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../dis:EndDateTime/@V"/>
				</xsl:call-template>
			</td>
		</xsl:if>
		<xsl:if test="//dis:InfItem[dis:Medication]/dis:OrgDate">
			<td colspan="{$med-odate-col}">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="../dis:OrgDate/@V"/>
				</xsl:call-template>
			</td>
		</xsl:if>
	</xsl:template>
	<!-- Visning av Pasient -->
	<xsl:template match="dis:Patient">
		<xsl:if test="dis:Sex or dis:DateOfBirth or dis:AdditionalId">
			<tr>
				<th rowspan="2">Pasientinfo</th>
				<xsl:if test="dis:Name">
					<th colspan="{(($std-col)-2)*number(not(dis:OffId | dis:Sex | dis:DateOfBirth | dis:DateOfDeath | dis:AdditionalId ))+1}">Navn</th>
				</xsl:if>
				<xsl:if test="dis:OffId">
					<th colspan="{(($std-col)-2-count(dis:Name))*number(not(dis:Sex | dis:DateOfBirth | dis:DateOfDeath | dis:AdditionalId))+1}">
						<xsl:for-each select="dis:TypeOffId">
							<xsl:call-template name="k-8116"/>&#160;
						</xsl:for-each>
					</th>
				</xsl:if>
				<xsl:if test="dis:Sex">
					<th colspan="{(($std-col)-2-count(dis:Name | dis:OffId))*number(not(dis:DateOfBirth | dis:DateOfDeath | dis:AdditionalId))+1}">Kjønn</th>
				</xsl:if>
				<xsl:if test="dis:DateOfBirth">
					<th colspan="{(($std-col)-2-count(dis:Name | dis:OffId | dis:Sex))*number(not(dis:DateOfDeath | dis:AdditionalId))+1}">Fødselsdag</th>
				</xsl:if>
				<xsl:if test="dis:DateOfDeath">
					<th colspan="{(($std-col)-2-count(dis:Name | dis:OffId | dis:Sex | dis:DateOfBirth))*number(not(dis:AdditionalId))+1}">Dødsdag</th>
				</xsl:if>
				<xsl:if test="dis:AdditionalId">
					<th colspan="{(($std-col)-1-count(dis:Name | dis:OffId | dis:Sex | dis:DateOfBirth | dis:DateOfDeath))}">Tilleggs-Id</th>
				</xsl:if>
			</tr>
			<tr>
				<xsl:if test="dis:Name">
					<td width="{((($std-col)-2)*number(not(dis:OffId | dis:Sex | dis:DateOfBirth | dis:DateOfDeath | dis:AdditionalId ))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(dis:OffId | dis:Sex | dis:DateOfBirth | dis:DateOfDeath | dis:AdditionalId ))+1}">
						<xsl:value-of select="dis:Name"/>
					</td>
				</xsl:if>
				<xsl:if test="dis:OffId">
					<td width="{((($std-col)-2-count(dis:Name))*number(not(dis:Sex | dis:DateOfBirth | dis:DateOfDeath | dis:AdditionalId))+1)*$std-td}px" colspan="{(($std-col)-2-count(dis:Name))*number(not(dis:Sex | dis:DateOfBirth | dis:DateOfDeath | dis:AdditionalId))+1}">
						<xsl:value-of select="dis:OffId"/>
					</td>
				</xsl:if>
				<xsl:if test="dis:Sex">
					<td width="{((($std-col)-2-count(dis:Name | dis:OffId))*number(not(dis:DateOfBirth | dis:DateOfDeath | dis:AdditionalId))+1)*$std-td}px" colspan="{(($std-col)-2-count(dis:Name | dis:OffId))*number(not(dis:DateOfBirth | dis:DateOfDeath | dis:AdditionalId))+1}">
						<xsl:for-each select="dis:Sex">
							<xsl:call-template name="k-3101"/>&#160;
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="dis:DateOfBirth">
					<td width="{((($std-col)-2-count(dis:Name | dis:OffId | dis:Sex))*number(not(dis:DateOfDeath | dis:AdditionalId))+1)*$std-td}px" colspan="{(($std-col)-2-count(dis:Name | dis:OffId | dis:Sex))*number(not(dis:DateOfDeath | dis:AdditionalId))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="dis:DateOfBirth/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="dis:DateOfDeath">
					<td width="{((($std-col)-2-count(dis:Name | dis:OffId | dis:Sex | dis:DateOfBirth))*number(not(dis:AdditionalId))+1)*$std-td}px" colspan="{(($std-col)-2-count(dis:Name | dis:OffId | dis:Sex | dis:DateOfBirth))*number(not(dis:AdditionalId))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="dis:DateOfDeath/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="dis:AdditionalId">
					<td colspan="{(($std-col)-1-count(dis:Name | dis:OffId | dis:Sex | dis:DateOfBirth | dis:DateOfDeath))}">
						<xsl:for-each select="dis:AdditionalId">
							<div>
								<xsl:if test="dis:Type"><b><xsl:value-of select="dis:Type/@V"/>:</b>&#160;</xsl:if>
								<xsl:value-of select="dis:Id"/>
							</div>
						</xsl:for-each>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:for-each select="dis:PatientPrecaution">
			<xsl:if test="position()=1">
				<xsl:if test="../dis:Sex or ../dis:DateOfBirth or ../dis:AdditionalId">
					<tr><td colspan="{$std-col}"><hr/></td></tr>
				</xsl:if>
				<tr>
					<th rowspan="{last()+1}">Advarsel til avsender</th>
					<xsl:if test="..//dis:PatientPrecaution/dis:Precaution">
						<th colspan="{(($std-col)-2)*number(not(..//dis:PatientPrecaution/dis:StartDateTime | ..//dis:PatientPrecaution/dis:EndDateTime))+1}">Advarsel</th>
					</xsl:if>
					<xsl:if test="..//dis:PatientPrecaution/dis:StartDateTime">
						<th colspan="{(($std-col)-2-number(boolean(..//dis:PatientPrecaution/dis:Precaution)))*number(not(..//dis:PatientPrecaution/dis:EndDateTime))+1}">Starttidspunkt</th>
					</xsl:if>
					<xsl:if test="..//dis:PatientPrecaution/dis:EndDateTime">
						<th colspan="{(($std-col)-1-number(boolean(..//dis:PatientPrecaution/dis:Precaution))-number(boolean(..//dis:PatientPrecaution/dis:StartDateTime)))}">Sluttidspunkt</th>
					</xsl:if>
				</tr>
			</xsl:if>
			<tr>
				<xsl:if test="..//dis:PatientPrecaution/dis:Precaution">
					<td width="{((($std-col)-2)*number(not(..//dis:PatientPrecaution/dis:StartDateTime | ..//dis:PatientPrecaution/dis:EndDateTime))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(..//dis:PatientPrecaution/dis:StartDateTime | ..//dis:PatientPrecaution/dis:EndDateTime))+1}">
						<xsl:value-of select="dis:Precaution"/>&#160;
					</td>
				</xsl:if>
				<xsl:if test="..//dis:PatientPrecaution/dis:StartDateTime">
					<td width="{((($std-col)-2-number(boolean(..//dis:PatientPrecaution/dis:Precaution)))*number(not(..//dis:PatientPrecaution/dis:EndDateTime))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//dis:PatientPrecaution/dis:Precaution)))*number(not(..//dis:PatientPrecaution/dis:EndDateTime))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="dis:StartDateTime/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="..//dis:PatientPrecaution/dis:EndDateTime">
					<td colspan="{(($std-col)-1-number(boolean(..//dis:PatientPrecaution/dis:Precaution))-number(boolean(..//dis:PatientPrecaution/dis:StartDateTime)))}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="dis:EndDateTime/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="dis:PatientRelParty">
			<xsl:if test="position()=1">
				<xsl:if test="../dis:Sex or ../dis:DateOfBirth or ../dis:AdditionalId or ../dis:PatientPrecaution">
					<tr><td colspan="{$std-col}"><hr/></td></tr>
				</xsl:if>
				<tr>
					<th rowspan="{last()+1}">Pasientrelatert part</th>
					<xsl:if test="..//dis:PatientRelParty/dis:Relation">
						<th colspan="{(($std-col)-2)*number(not(..//dis:PatientRelParty/dis:Name | ..//dis:PatientRelParty/dis:RelPartyOffId | ..//dis:PatientRelParty/dis:Address))+1}">Relasjon</th>
					</xsl:if>
					<xsl:if test="..//dis:PatientRelParty/dis:Name">
						<th colspan="{(($std-col)-2-number(boolean(..//dis:PatientRelParty/dis:Relation)))*number(not(..//dis:PatientRelParty/dis:RelPartyOffId | ..//dis:PatientRelParty/dis:Address))+1}">Navn</th>
					</xsl:if>
					<xsl:if test="..//dis:PatientRelParty/dis:RelPartyOffId">
						<th colspan="{(($std-col)-2-number(boolean(..//dis:PatientRelParty/dis:Relation))-number(boolean(..//dis:PatientRelParty/dis:Name)))*number(not(..//dis:PatientRelParty/dis:Address))+1}">Fødselsnummer</th>
					</xsl:if>
					<xsl:if test="..//dis:PatientRelParty/dis:Address">
						<th colspan="{(($std-col)-1-number(boolean(..//dis:PatientRelParty/dis:Relation))-number(boolean(..//dis:PatientRelParty/dis:Name))-number(boolean(..//dis:PatientRelParty/dis:RelPartyOffId)))}">Adresse</th>
					</xsl:if>
				</tr>
			</xsl:if>
			<tr>
				<xsl:if test="..//dis:PatientRelParty/dis:Relation">
					<td width="{((($std-col)-2)*number(not(..//dis:PatientRelParty/dis:Name | ..//dis:PatientRelParty/dis:RelPartyOffId | ..//dis:PatientRelParty/dis:Address))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(..//dis:PatientRelParty/dis:Name | ..//dis:PatientRelParty/dis:RelPartyOffId | ..//dis:PatientRelParty/dis:Address))+1}">
						<xsl:for-each select="dis:Relation">
							<xsl:call-template name="k-7317"/>&#160;
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="..//dis:PatientRelParty/dis:Name">
					<td width="{((($std-col)-2-number(boolean(..//dis:PatientRelParty/dis:Relation)))*number(not(..//dis:PatientRelParty/dis:RelPartyOffId | ..//dis:PatientRelParty/dis:Address))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//dis:PatientRelParty/dis:Relation)))*number(not(..//dis:PatientRelParty/dis:RelPartyOffId | ..//dis:PatientRelParty/dis:Address))+1}">
						<xsl:value-of select="dis:Name"/>
					</td>
				</xsl:if>
				<xsl:if test="..//dis:PatientRelParty/dis:RelPartyOffId">
					<td width="{((($std-col)-2-number(boolean(..//dis:PatientRelParty/dis:Relation))-number(boolean(..//dis:PatientRelParty/dis:Name)))*number(not(..//dis:PatientRelParty/dis:Address))+1)*$std-td}px" colspan="{(($std-col)-2-number(boolean(..//dis:PatientRelParty/dis:Relation))-number(boolean(..//dis:PatientRelParty/dis:Name)))*number(not(..//dis:PatientRelParty/dis:Address))+1}">
						<xsl:value-of select="dis:RelPartyOffId"/>
					</td>
				</xsl:if>
				<xsl:if test="..//dis:PatientRelParty/dis:Address">
					<td colspan="{(($std-col)-1-number(boolean(..//dis:PatientRelParty/dis:Relation))-number(boolean(..//dis:PatientRelParty/dis:Name))-number(boolean(..//dis:PatientRelParty/dis:RelPartyOffId)))}">
						<xsl:apply-templates select="dis:Address"/>
					</td>
				</xsl:if>
			</tr>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Hendelse -->
	<xsl:template match="dis:Event">
		<tr>
			<td width="{$event-type-col*$std-td}px" colspan="{$event-type-col}">
				<span class="strong">
					<xsl:if test="local-name(..)=&quot;Event&quot;">Del-hendelse:&#160;</xsl:if>
					<xsl:for-each select="dis:Service/dis:AdmCat">
						<xsl:call-template name="k-8240"/>&#160;
					</xsl:for-each>
				</span>
				<xsl:if test="dis:ServType/@V != &quot;N&quot;">
					<div><b>Tjenstetype:&#160;</b>
						<xsl:for-each select="dis:ServType">
							<xsl:call-template name="k-7309"/>&#160;
						</xsl:for-each>
					</div>
				</xsl:if>
				<xsl:if test="dis:Recipient/@V != &quot;1&quot;">
					<div>
						(<xsl:for-each select="dis:Recipient">
							<xsl:call-template name="k-8250"/>&#160;
						</xsl:for-each>)
					</div>
				</xsl:if>
			</td>
			<xsl:if test="..//dis:EventLocation">
				<td width="{$event-place-col*$std-td}px" colspan="{$event-place-col}">
					<xsl:if test="dis:EventLocation/dis:Location/dis:Inst">
						<div>
							<xsl:if test="dis:EventLocation/dis:Location/dis:Inst/dis:Name">
								<xsl:value-of select="dis:EventLocation/dis:Location/dis:Inst/dis:Name"/>&#160;
							</xsl:if>
							<xsl:if test="dis:EventLocation/dis:Location/dis:Inst/dis:Name and dis:EventLocation/dis:Location/dis:Inst/dis:Dept/dis:Name">-&#160;</xsl:if>
							<xsl:if test="dis:EventLocation/dis:Location/dis:Inst/dis:Dept/dis:Name">
								<xsl:value-of select="dis:EventLocation/dis:Location/dis:Inst/dis:Dept/dis:Name"/>&#160;
							</xsl:if>
							<xsl:if test="dis:EventLocation/dis:Location/dis:SubLocation/dis:Place">
								<xsl:value-of select="dis:EventLocation/dis:Location/dis:SubLocation/dis:Place"/>&#160;
							</xsl:if>
						</div>
					</xsl:if>
					<xsl:if test="dis:EventLocation/dis:Role">
						<div><b>Rolle:&#160;</b>
							<xsl:for-each select="dis:EventLocation/dis:Role">
								<xsl:call-template name="k-8251"/>&#160;
							</xsl:for-each>
							<xsl:for-each select="dis:EventLocation/dis:Location/dis:SubLocation/dis:Type">
								<xsl:call-template name="k-8242"/>&#160;
							</xsl:for-each>
						</div>
					</xsl:if>
					<xsl:if test="dis:EventLocation/dis:Location/dis:Address">
						<div>
							<xsl:apply-templates select="dis:EventLocation/dis:Location/dis:Address"/>
						</div>
					</xsl:if>
				</td>
			</xsl:if>
			<xsl:if test="..//dis:ReportedEvent/dis:StartDateTime or ..//dis:ReportedEvent/dis:EndDateTime or ..//dis:ExpDuration">
				<td width="{$event-time-col*$std-td}px" colspan="{$event-time-col}">
					<xsl:if test="dis:ReportedEvent/dis:StartDateTime">
						<span class="strong">Start:&#160;</span>
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="dis:ReportedEvent/dis:StartDateTime/@V"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="dis:ReportedEvent/dis:EndDateTime">
						<span class="strong">Slutt:&#160;</span>
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="dis:ReportedEvent/dis:EndDateTime/@V"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="dis:EventLocation/dis:StartDateTime or dis:EventLocation/dis:EndDateTime">
						<div>
							<xsl:if test="dis:EventLocation/dis:StartDateTime">
								<span class="strong">Lokasjonstart:&#160;</span>
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="dis:EventLocation/dis:StartDateTime/@V"/>
								</xsl:call-template>
							</xsl:if>
							<xsl:if test="dis:EventLocation/dis:EndDateTime">
								<span class="strong">Lokasjonslutt:&#160;</span>
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="dis:EventLocation/dis:EndDateTime/@V"/>
								</xsl:call-template>
							</xsl:if>
						</div>
					</xsl:if>
					<xsl:if test="dis:ExpDuration">
						<div><b>Forventet&#160;varighet:&#160;</b>
						<xsl:value-of select="dis:ExpDuration/@V"/><xsl:value-of select="dis:ExpDuration/@U"/>
						</div>
					</xsl:if>
				</td>
			</xsl:if>
			<xsl:if test="..//dis:AdmOutcome">
				<td width="{$event-out-col*$std-td}px" colspan="{$event-out-col}">
					<xsl:for-each select="dis:AdmOutcome">
						<xsl:call-template name="k-7300"/>&#160;
					</xsl:for-each>
				</td>
			</xsl:if>
			<xsl:if test="..//dis:Priority">
				<td width="{$event-pri-col*$std-td}px" colspan="{$event-pri-col}">
					<xsl:for-each select="dis:Priority">
						<xsl:call-template name="k-8304"/>&#160;
					</xsl:for-each>
				</td>
			</xsl:if>
			<xsl:if test="..//dis:AssRequest">
				<td colspan="{$event-ass-col}">
					<xsl:for-each select="dis:AssRequest/dis:MsgType">
						<xsl:call-template name="k-7315"/>&#160;
					</xsl:for-each>
					<xsl:if test="dis:AssRequest/dis:IssueDate">
						<div><b>Utsted:&#160;</b>
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="dis:AssRequest/dis:IssueDate/@V"/>
							</xsl:call-template>
						</div>
					</xsl:if>
				</td>
			</xsl:if>
		</tr>
	</xsl:template>
	<!-- Visning av Tjenesteyter -->
	<xsl:template match="dis:ServProvider">
		<xsl:param name="col"/>
		<tr>
			<th colspan="{$col}" class="h3">Avsender<xsl:if test="dis:HCP/dis:MedSpeciality"> - Spesialitet:&#160;<xsl:for-each select="dis:HCP/dis:MedSpeciality">
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
		<xsl:for-each select="dis:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Henvisende instans -->
	<xsl:template match="dis:Requester">
		<xsl:param name="col"/>
		<tr>
			<th colspan="{$col}" class="h3">Mottaker<xsl:if test="dis:HCP/dis:MedSpeciality"> - Spesialitet:&#160;<xsl:for-each select="dis:HCP/dis:MedSpeciality">
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
		<xsl:for-each select="dis:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Kopimottaker -->
	<xsl:template match="dis:CopyDest">
		<xsl:param name="col"/>
		<tr>
			<th colspan="{$col}" class="h3">Kopimottaker<xsl:if test="dis:CopyDestRole/dis:MsgType"> - kopi&#160;av:&#160;<xsl:for-each select="dis:CopyDestRole/dis:MsgType">
						<xsl:call-template name="k-8279"/>
					</xsl:for-each>
				</xsl:if>
			</th>
		</tr>
		<xsl:for-each select="dis:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Tilknyttet tjeneteyter -->
	<xsl:template match="dis:RelServProvider">
		<xsl:param name="col"/>
		<tr>
			<th colspan="{$col}" class="h3">
				<xsl:for-each select="dis:Relation">
					<xsl:call-template name="k-8254"/>
				</xsl:for-each>
			</th>
		</tr>
		<xsl:for-each select="dis:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Opprinnelse til klinisk opplysning -->
	<xsl:template match="dis:Origin">
		<xsl:param name="col"/>
		<tr>
			<th colspan="{$col}" class="h3">Opprinnelse&#160;til&#160;klinisk&#160;opplysning<xsl:if test="dis:HCP/dis:MedSpeciality"> - Spesialitet:&#160;<xsl:for-each select="dis:HCP/dis:MedSpeciality">
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
		<xsl:for-each select="dis:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Tilknyttet klinisk tjenesteyter -->
	<xsl:template match="dis:RelHCProvider">
		<xsl:param name="col"/>
		<tr>
			<th colspan="{$col}" class="h3">
				<xsl:for-each select="dis:Relation">
					<xsl:call-template name="k-7318"/>
				</xsl:for-each>
			</th>
		</tr>
		<xsl:for-each select="dis:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Tilknyttet klinisk tjenesteyter -->
	<xsl:template match="dis:PatRelHCP">
		<xsl:param name="col"/>
		<tr>
			<th colspan="{$col}" class="h3">
				<xsl:for-each select="dis:Relation">
					<xsl:call-template name="k-8254"/>
				</xsl:for-each>
				<xsl:if test="dis:StartDateTime or dis:EndDateTime">&#160;Tidsrom:&#160;<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="dis:StartDateTime/@V"/>
					</xsl:call-template>&#160;-:&#160;<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="dis:EndDateTime/@V"/>
					</xsl:call-template>&#160;
				</xsl:if>
			</th>
		</tr>
		<xsl:for-each select="dis:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Helsetjenesteenhet -->
	<xsl:template match="dis:HCP">
		<xsl:param name="col"/>
		<xsl:for-each select="dis:Inst">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="dis:Inst/dis:Dept">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="dis:Inst/dis:HCPerson">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="dis:HCProf">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="dis:Address">
			<xsl:variable name="antall-tel" select="count(dis:TeleAddress)"/>
			<tr>
				<xsl:apply-templates select="dis:TeleAddress">
					<xsl:with-param name="col" select="(($col)-1)*number(not(dis:Type and (dis:PostalCode or dis:City)))+1"/>
				</xsl:apply-templates>
				<xsl:if test="dis:Type and (dis:PostalCode or dis:City)">
					<xsl:apply-templates select=".">
						<xsl:with-param name="col" select="($col)-1-($antall-tel)*2"/>
					</xsl:apply-templates>
				</xsl:if>
			</tr>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Person i helsevesenet -->
	<xsl:template match="dis:HCProf">
		<xsl:param name="col"/>
		<xsl:if test="dis:Type or dis:Name">
			<th>
				<xsl:choose>
					<xsl:when test="dis:Type">
						<xsl:for-each select="dis:Type">
							<xsl:call-template name="k-9060"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Helsepersonell</xsl:otherwise>
				</xsl:choose>
			</th>
			<td width="{$std-td}px">
				<xsl:value-of select="dis:Name"/>
			</td>
		</xsl:if>
		<xsl:if test="dis:Id or dis:AdditionalId">
			<th>
				<xsl:choose>
					<xsl:when test="dis:TypeId">
						<xsl:for-each select="dis:TypeId">
							<xsl:call-template name="k-8116"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Id</xsl:otherwise>
				</xsl:choose>
			</th>
			<xsl:choose>
				<xsl:when test="dis:AdditionalId">
					<td width="{$std-td}px">
						<xsl:value-of select="dis:Id"/>
					</td>
				</xsl:when>
				<xsl:otherwise>
					<td colspan="{($col)-3}">
						<xsl:value-of select="dis:Id"/>
					</td>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="dis:AdditionalId">
				<xsl:variable name="antall-id" select="count(dis:AdditionalId)"/>
				<xsl:for-each select="dis:AdditionalId">
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
		</xsl:if>
	</xsl:template>
	<!-- Visning av Institusjon -->
	<xsl:template match="dis:Inst">
		<xsl:param name="col"/>
		<xsl:if test="dis:Name">
			<th>Navn</th>
			<td width="{$std-td}px">
				<xsl:value-of select="dis:Name"/>
			</td>
		</xsl:if>
		<xsl:if test="dis:Id or dis:AdditionalId">
			<th>
				<xsl:choose>
					<xsl:when test="dis:TypeId">
						<xsl:for-each select="dis:TypeId">
							<xsl:call-template name="k-9051"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Id</xsl:otherwise>
				</xsl:choose>
			</th>
			<xsl:choose>
				<xsl:when test="dis:AdditionalId">
					<td width="{$std-td}px">
						<xsl:value-of select="dis:Id"/>
					</td>
				</xsl:when>
				<xsl:otherwise>
					<td colspan="{($col)-3}">
						<xsl:value-of select="dis:Id"/>
					</td>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="dis:AdditionalId">
				<xsl:variable name="antall-id" select="count(dis:AdditionalId)"/>
				<xsl:for-each select="dis:AdditionalId">
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
		</xsl:if>
	</xsl:template>
	<!-- Visning av Avdeling -->
	<xsl:template match="dis:Dept">
		<xsl:param name="col"/>
		<xsl:if test="dis:Type or dis:Name">
			<th>
				<xsl:choose>
					<xsl:when test="dis:Type">
						<xsl:for-each select="dis:Type">
							<xsl:call-template name="k-8624"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Avdeling</xsl:otherwise>
				</xsl:choose>
			</th>
			<td width="{$std-td}px">
				<xsl:value-of select="dis:Name"/>
			</td>
		</xsl:if>
		<xsl:if test="dis:Id or dis:AdditionalId">
			<th>
				<xsl:choose>
					<xsl:when test="dis:TypeId">
						<xsl:for-each select="dis:TypeId">
							<xsl:call-template name="k-9051"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Id</xsl:otherwise>
				</xsl:choose>
			</th>
			<xsl:choose>
				<xsl:when test="dis:AdditionalId">
					<td width="{$std-td}px">
						<xsl:value-of select="dis:Id"/>
					</td>
				</xsl:when>
				<xsl:otherwise>
					<td colspan="{($col)-3}">
						<xsl:value-of select="dis:Id"/>
					</td>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="dis:AdditionalId">
				<xsl:variable name="antall-id" select="count(dis:AdditionalId)"/>
				<xsl:for-each select="dis:AdditionalId">
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
		</xsl:if>
	</xsl:template>
	<!-- Visning av Person i organisasjon -->
	<xsl:template match="dis:HCPerson">
		<xsl:param name="col"/>
		<xsl:if test="dis:Name">
			<th>Helsepersonell</th>
			<td width="{$std-td}px">
				<xsl:value-of select="dis:Name"/>
			</td>
		</xsl:if>
		<xsl:if test="dis:Id or dis:AdditionalId">
			<th>
				<xsl:choose>
					<xsl:when test="dis:TypeId">
						<xsl:for-each select="dis:TypeId">
							<xsl:call-template name="k-8116"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Id</xsl:otherwise>
				</xsl:choose>
			</th>
			<xsl:choose>
				<xsl:when test="dis:AdditionalId">
					<td width="{$std-td}px">
						<xsl:value-of select="dis:Id"/>
					</td>
				</xsl:when>
				<xsl:otherwise>
					<td colspan="{($col)-3}">
						<xsl:value-of select="dis:Id"/>
					</td>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="dis:AdditionalId">
				<xsl:variable name="antall-id" select="count(dis:AdditionalId)"/>
				<xsl:for-each select="dis:AdditionalId">
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
		</xsl:if>
	</xsl:template>
	<!-- Visning av Alternativ id -->
	<xsl:template match="dis:AdditionalId">
		<xsl:param name="col"/>
		<th>
			<xsl:for-each select="dis:Type">
				<xsl:choose>
					<xsl:when test="local-name(../..)='Patient' or local-name(../..)='HCProf' or local-name(../..)='HCPerson'">
						<xsl:call-template name="k-8116"/>
					</xsl:when>
					<xsl:when test="local-name(..)='Inst' or local-name(..)='Dept'">
						<xsl:call-template name="k-9051"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="k-dummy"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</th>
		<td colspan="{$col}">
			<xsl:value-of select="dis:Id"/>
		</td>
	</xsl:template>
	<!-- Visning av Adresse -->
	<xsl:template match="dis:Address">
		<xsl:param name="col"/>
		<th>
			<xsl:choose>
				<xsl:when test="dis:Type">
					<xsl:for-each select="dis:Type">
						<xsl:call-template name="k-3401"/>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>Adresse</xsl:otherwise>
			</xsl:choose>
		</th>
		<td colspan="{$col}">
			<xsl:if test="dis:StreetAdr">
				<xsl:value-of select="dis:StreetAdr"/>,&#160;</xsl:if>
			<xsl:if test="dis:PostalCode">
				<xsl:value-of select="dis:PostalCode"/>
			</xsl:if>
			<xsl:if test="dis:City">&#160;<xsl:value-of select="dis:City"/>
			</xsl:if>
			<xsl:if test="dis:CityDistr">,&#160;<xsl:for-each select="dis:CityDistr"><xsl:call-template name="k-3403"/></xsl:for-each>
			</xsl:if>
			<xsl:if test="dis:County">,&#160;<xsl:for-each select="dis:County"><xsl:call-template name="k-3402"/></xsl:for-each>
			</xsl:if>
			<xsl:if test="dis:Country">,&#160;<xsl:for-each select="dis:Country"><xsl:call-template name="k-9043"/></xsl:for-each>
			</xsl:if>
		</td>
	</xsl:template>
	<!-- Visning av Telekommunikasjon -->
	<xsl:template match="dis:TeleAddress">
		<xsl:param name="col"/>
		<th>
			<xsl:choose>
				<xsl:when test="starts-with(@V, 'tel:') or starts-with(@V, 'callto:')">Telefon</xsl:when>
				<xsl:when test="starts-with(@V, 'fax:')">Faks</xsl:when>
				<xsl:when test="starts-with(@V, 'mailto:')">e-post</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-before(@V, ':')"/>
				</xsl:otherwise>
			</xsl:choose>
		</th>
		<td colspan="{$col}">
			<xsl:value-of select="substring-after(@V, ':')"/>
		</td>
	</xsl:template>
	<!-- Visning av vedllegg -->
	<xsl:template match="dis:RefDoc">
		<xsl:param name="col"/>
		<xsl:if test="dis:MsgType or dis:Id or dis:IssueDate or dis:MimeType or dis:Compression">
			<tr>
				<xsl:if test="dis:MsgType">
					<th>Type</th>
					<td width="{((($col)-2)*number(not(dis:Id | dis:IssueDate | dis:MimeType | dis:Compression))+1)*$std-td}px" colspan="{(($col)-2)*number(not(dis:Id | dis:IssueDate | dis:MimeType | dis:Compression))+1}">
						<xsl:for-each select="dis:MsgType">
							<xsl:call-template name="k-8114"/>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="dis:Id">
					<th>Id</th>
					<td width="{((($col)-2-count(dis:MsgType)*2)*number(not(dis:IssueDate | dis:MimeType | dis:Compression))+1)*$std-td}px" colspan="{(($col)-2-count(dis:MsgType)*2)*number(not(dis:IssueDate | dis:MimeType | dis:Compression))+1}">
						<xsl:value-of select="dis:Id"/>
					</td>
				</xsl:if>
				<xsl:if test="dis:IssueDate">
					<th>Utstedt-dato</th>
					<td width="{((($col)-2-count(dis:MsgType | dis:Id)*2)*number(not(dis:MimeType | dis:Compression))+1)*$std-td}px" colspan="{(($col)-2-count(dis:MsgType | dis:Id)*2)*number(not(dis:MimeType | dis:Compression))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="dis:IssueDate/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="dis:MimeType">
					<th>Mimetype</th>
					<td width="{((($col)-2-count(dis:MsgType | dis:Id | dis:IssueDate)*2)*number(not(dis:Compression))+1)*$std-td}px" colspan="{(($col)-2-count(dis:MsgType | dis:Id | dis:IssueDate)*2)*number(not(dis:Compression))+1}">
						<xsl:value-of select="dis:MimeType"/>
					</td>
				</xsl:if>
				<xsl:if test="dis:Compression">
					<th>Komprimering</th>
					<td colspan="{($col)-1-count(dis:MsgType | dis:Id | dis:IssueDate | dis:MimeType)*2}">
						<xsl:for-each select="dis:Compression">
							<xsl:call-template name="k-1204"/>
						</xsl:for-each>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="dis:Description">
			<tr>
				<th>Beskrivelse</th>
				<td colspan="{($col)-1}">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="dis:Description"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="dis:Content or dis:FileReference">
			<xsl:choose>
				<xsl:when test="contains(dis:MimeType,'image')">
					<tr>
						<th>Bilde</th>
						<xsl:choose>
							<xsl:when test="dis:FileReference">
								<td colspan="{($col)-1}">
									<img>
										<xsl:attribute name="src"><xsl:value-of select="dis:FileReference"/></xsl:attribute>
										<xsl:attribute name="alt">Bilde fra ekstern URL</xsl:attribute>
									</img>
								</td>
							</xsl:when>
							<xsl:when test="dis:Content">
								<td colspan="{($col)-1}">
									<xsl:choose>
										<xsl:when test="dis:Content/base:Base64Container">
											<img>
												<xsl:attribute name="src"><xsl:value-of select="concat('data:',dis:MimeType,';base64,',dis:Content/base:Base64Container)"/></xsl:attribute>
												<xsl:attribute name="alt">Bilde vedlagt som base64-kode</xsl:attribute>
											</img>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="dis:Content"/>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:when>
						</xsl:choose>
					</tr>
				</xsl:when>
				<xsl:when test="contains(dis:MimeType,'pdf')">
					<tr>
						<th>pdf</th>
						<xsl:choose>
							<xsl:when test="dis:FileReference">
								<td colspan="{($col)-1}">
									<object>
										<xsl:attribute name="data"><xsl:value-of select="concat(dis:FileReference,'&#35;view&#61;FitH&#38;toolbar&#61;1')"/></xsl:attribute>
										<xsl:attribute name="type">application/pdf</xsl:attribute>
										<xsl:attribute name="width">100%</xsl:attribute>
										<xsl:attribute name="height">500px</xsl:attribute>
									</object>
								</td>
							</xsl:when>
							<xsl:when test="dis:Content">
								<td colspan="{($col)-1}">
									<xsl:choose>
										<xsl:when test="dis:Content/base:Base64Container">
											<object>
												<xsl:attribute name="data"><xsl:value-of select="concat('data:application/pdf;base64,',dis:Content/base:Base64Container)"/></xsl:attribute>
												<xsl:attribute name="type">application/pdf</xsl:attribute>
												<xsl:attribute name="width">100%</xsl:attribute>
												<xsl:attribute name="height">500px</xsl:attribute>
											</object>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="dis:Content"/>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:when>
						</xsl:choose>
					</tr>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="dis:Content">
							<xsl:value-of select="dis:Content"/>
						</xsl:when>
						<xsl:when test="dis:FileReference">
							<xsl:value-of select="dis:FileReference"/>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
