<?xml version="1.0" encoding="utf-8"?>
	<!-- Endringslogg
	- 17.10.23: v3.1.4: Endret SNOMED til NORPAT
	- 15.05.17: v3.1.3: Endret tekst på akkreditering for prøvetaking og resultat. Endret tekst fra tjenesteyter til avsender og mottaker
	- 27.03.17: v3.1.2: Ny parameter for "visningStil. Ny stil "Smooth"
	- 03.01.17: v3.1.1: Lagt til konvertering av linjeskift for felt ResultItem/StructuredInfo/TextInfo/Text
	- 24.04.16: Historikk får egen tabell. Egne kolonner i undersøkelsestabellen for prøve-referanser. Bruk av kodeverk 8212 vises med OT. Bruk av 7010 vises med V og DN.
	- 11.04.16: Fjernet gjennomstreking av historikk
	- 15.05.14: La til import av kodeverk-fil
	- 01.02.14: Versjon 1.4
	- 01.12.10: Rettet Avsender og mottaker som var byttet om. Import av felles CSS-fil.
	- 23.04.10: La til visning av interne referanser ved bruk av IdResultItem of RefIdResultItem.
	- 10.07.09: Felles komplett visningsfil for svarrapport.
	- 04.02.09: Oppdatert adresse for namespace for v1.3
	- 23.06.08: Versjon etter QA
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
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:lsr="http://www.kith.no/xmlstds/labsvar/2012-02-15"
	xmlns:base="http://www.kith.no/xmlstds/base64container"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="lsr base xhtml">

	<xsl:import href="../../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../../felleskomponenter/kodeverk.xsl"/>
	<xsl:import href="../../felleskomponenter/visningstil.xsl"/>


	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'svar1.4 - v3.1.4'"/>
	<!-- Variabler for kolonnebredde -->
	<xsl:variable name="structured-col-width" select="'40%'"/>
	<xsl:variable name="structured-head-width" select="'20%'"/>
	<!-- Variabler for antall kolonner og bredde -->
	<xsl:variable name="result-col" select="10"/>
	<xsl:variable name="result-td" select="150"/>
	<xsl:variable name="id-td" select="25"/>
	<xsl:variable name="std-col" select="10"/>
	<xsl:variable name="std-td" select="200"/>
	<!-- Variabler for bruk til referanser i undersøkelsestabellen -->
	<xsl:variable name="und-komm" select="'k'"/>
	<xsl:variable name="und-spes" select="'s'"/>
	<xsl:variable name="res-komm" select="'r'"/>
	<xsl:variable name="dia-komm" select="'d'"/>
	<!-- (hårete) Variabler for beregning av antall kolonner i undersøkelsestabellen -->
	<xsl:variable name="investigation-col" select="(($result-col)-1)*number(not(//lsr:TextResult | //lsr:Interval | //lsr:DateResult | //lsr:NumResult | //lsr:IdResultItem | //lsr:RefIdResultItem | //lsr:RefInterval  | //lsr:InvDate | //lsr:StatusChangeDate | //lsr:DescrDate | //lsr:CounterSignDate | //lsr:MedicalValidationDate | //lsr:ResultItem/lsr:RelServProv | //lsr:ResultItem/lsr:Accredited | //lsr:StructuredInfo | //lsr:Investigation/lsr:Comment | //lsr:Investigation/lsr:Spec | //lsr:ResultItem/lsr:Comment | //lsr:ResultItem/lsr:DiagComment | //lsr:RefAnalysedSubject | //lsr:StatusInvestigation))+1"/>
	<xsl:variable name="res-col" select="(($result-col)-1-number(boolean(//lsr:Investigation)))*number(not(//lsr:IdResultItem | //lsr:RefIdResultItem | //lsr:RefInterval  | //lsr:InvDate | //lsr:StatusChangeDate | //lsr:DescrDate | //lsr:CounterSignDate | //lsr:MedicalValidationDate | //lsr:ResultItem/lsr:RelServProv | //lsr:ResultItem/lsr:Accredited | //lsr:StructuredInfo | //lsr:Investigation/lsr:Comment | //lsr:Investigation/lsr:Spec | //lsr:ResultItem/lsr:Comment | //lsr:ResultItem/lsr:DiagComment | //lsr:RefAnalysedSubject | //lsr:StatusInvestigation))+1"/>
	<xsl:variable name="id-col" select="(($result-col)-1-number(boolean(//lsr:Investigation))-number(boolean(//lsr:TextResult or //lsr:Interval or //lsr:DateResult or //lsr:NumResult)))*number(not(//lsr:RefIdResultItem | //lsr:RefInterval  | //lsr:InvDate | //lsr:StatusChangeDate | //lsr:DescrDate | //lsr:CounterSignDate | //lsr:MedicalValidationDate | //lsr:ResultItem/lsr:RelServProv | //lsr:ResultItem/lsr:Accredited | //lsr:StructuredInfo | //lsr:Investigation/lsr:Comment | //lsr:Investigation/lsr:Spec | //lsr:ResultItem/lsr:Comment | //lsr:ResultItem/lsr:DiagComment | //lsr:RefAnalysedSubject | //lsr:StatusInvestigation))+1"/>
	<xsl:variable name="refid-col" select="(($result-col)-1-number(boolean(//lsr:Investigation))-number(boolean(//lsr:TextResult or //lsr:Interval or //lsr:DateResult or //lsr:NumResult))-number(boolean(//lsr:IdResultItem)))*number(not(//lsr:RefInterval  | //lsr:InvDate | //lsr:StatusChangeDate | //lsr:DescrDate | //lsr:CounterSignDate | //lsr:MedicalValidationDate | //lsr:ResultItem/lsr:RelServProv | //lsr:ResultItem/lsr:Accredited | //lsr:StructuredInfo | //lsr:Investigation/lsr:Comment | //lsr:Investigation/lsr:Spec | //lsr:ResultItem/lsr:Comment | //lsr:ResultItem/lsr:DiagComment | //lsr:RefAnalysedSubject | //lsr:StatusInvestigation))+1"/>
	<xsl:variable name="refinterval-col" select="(($result-col)-1-number(boolean(//lsr:Investigation))-number(boolean(//lsr:TextResult or //lsr:Interval or //lsr:DateResult or //lsr:NumResult))-number(boolean(//lsr:IdResultItem))-number(boolean(//lsr:RefIdResultItem)))*number(not(//lsr:InvDate | //lsr:StatusChangeDate | //lsr:DescrDate | //lsr:CounterSignDate | //lsr:MedicalValidationDate | //lsr:ResultItem/lsr:RelServProv | //lsr:ResultItem/lsr:Accredited | //lsr:StructuredInfo | //lsr:Investigation/lsr:Comment | //lsr:Investigation/lsr:Spec | //lsr:ResultItem/lsr:Comment | //lsr:ResultItem/lsr:DiagComment | //lsr:RefAnalysedSubject | //lsr:StatusInvestigation))+1"/>
	<xsl:variable name="date-col" select="(($result-col)-1-number(boolean(//lsr:Investigation))-number(boolean(//lsr:TextResult or //lsr:Interval or //lsr:DateResult or //lsr:NumResult))-number(boolean(//lsr:IdResultItem))-number(boolean(//lsr:RefIdResultItem))-number(boolean(//lsr:RefInterval)))*number(not(//lsr:DescrDate | //lsr:CounterSignDate | //lsr:MedicalValidationDate | //lsr:ResultItem/lsr:RelServProv | //lsr:ResultItem/lsr:Accredited | //lsr:StructuredInfo | //lsr:Investigation/lsr:Comment | //lsr:Investigation/lsr:Spec | //lsr:ResultItem/lsr:Comment | //lsr:ResultItem/lsr:DiagComment | //lsr:RefAnalysedSubject | //lsr:StatusInvestigation))+1"/>
	<xsl:variable name="relserv-col" select="(($result-col)-1-number(boolean(//lsr:Investigation))-number(boolean(//lsr:TextResult or //lsr:Interval or //lsr:DateResult or //lsr:NumResult))-number(boolean(//lsr:IdResultItem))-number(boolean(//lsr:RefIdResultItem))-number(boolean(//lsr:RefInterval))-number(boolean(//lsr:InvDate or //lsr:StatusChangeDate or //lsr:DescrDate or //lsr:CounterSignDate or //lsr:MedicalValidationDate)))*number(not(//lsr:ResultItem/lsr:Accredited | //lsr:StructuredInfo | //lsr:Investigation/lsr:Comment | //lsr:Investigation/lsr:Spec | //lsr:ResultItem/lsr:Comment | //lsr:ResultItem/lsr:DiagComment | //lsr:RefAnalysedSubject | //lsr:StatusInvestigation))+1"/>
	<xsl:variable name="tillegg-col" select="($result-col)-number(boolean(//lsr:Investigation))-number(boolean(//lsr:TextResult or //lsr:Interval or //lsr:DateResult or //lsr:NumResult))-number(boolean(//lsr:IdResultItem))-number(boolean(//lsr:RefIdResultItem))-number(boolean(//lsr:RefInterval))-number(boolean(//lsr:InvDate or //lsr:StatusChangeDate or //lsr:DescrDate or //lsr:CounterSignDate or //lsr:MedicalValidationDate))-number(boolean(//lsr:ResultItem/lsr:RelServProv))"/>

	<!-- Meldingsstart -->
	<xsl:template match="/">
		<html>
			<head>
				<title>Svarrapport</title>
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

	<xsl:template match="lsr:Message">
		<xsl:for-each select="lsr:ServReport">
			<!-- utelater meldingsid og kommunikasjonsinformasjon -->
			<xsl:call-template name="Header"/>
			<xsl:call-template name="ResultBody"/>
			<xsl:call-template name="Footer"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Header - avsender og mottaker-informasjon -->
	<xsl:template name="Header">
		<div class="No-line-top">
			<div class="No-line-header">
				<div class="No-line-headerContent">
					<div class="No-line-caption">Avsender &#160;</div>
					<div class="No-line-content">
						<xsl:apply-templates select="lsr:ServProvider" mode="hode"/>
					</div>
				</div>
				<xsl:choose>
					<xsl:when test="lsr:Patient">
						<div class="No-line-headerContent">
							<div class="No-line-caption">Pasient&#160;</div>
							<div class="No-line-content">
								<xsl:apply-templates select="lsr:Patient" mode="hode"/>
							</div>
						</div>
					</xsl:when>
					<xsl:when test="lsr:Animal">
						<div class="No-line-headerContent">
							<div class="No-line-caption">Undersøkelsesdyr&#160;</div>
							<div class="No-line-content">
								<xsl:apply-templates select="lsr:Animal" mode="hode"/>
							</div>
						</div>
					</xsl:when>
					<xsl:when test="lsr:Material">
						<div class="No-line-headerContent">
							<div class="No-line-caption">Materiale&#160;</div>
							<div class="No-line-content">
								<xsl:apply-templates select="lsr:Material" mode="hode"/>
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
						<xsl:apply-templates select="lsr:Requester" mode="hode"/>
					</div>
				</div>
				<xsl:choose>
					<xsl:when test="lsr:CopyDest">
						<div class="No-line-headerContent">
							<div class="No-line-caption">Kopimottaker&#160;</div>
							<div class="No-line-content">
								<xsl:apply-templates select="lsr:CopyDest" mode="hode"/>
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
	<xsl:template match="lsr:ServProvider" mode="hode">
		<xsl:apply-templates select="lsr:HCP" mode="hode"/>
	</xsl:template>
	<xsl:template match="lsr:Requester" mode="hode">
		<xsl:apply-templates select="lsr:HCP" mode="hode"/>
	</xsl:template>
	<xsl:template match="lsr:Patient" mode="hode">
		<div>
			<xsl:value-of select="lsr:Name"/>&#160;
			<span class="strong">
				<xsl:for-each select="lsr:TypeOffId">
					<xsl:call-template name="k-8116"/>
				</xsl:for-each>:&#160;</span>
			<xsl:value-of select="lsr:OffId"/>&#160;
		</div>
		<xsl:if test="lsr:DateOfDeath">
			<div>
				<span class="strong">Dødsdato:&#160;</span>
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="lsr:DateOfDeath/@V"/>
				</xsl:call-template>
			</div>
		</xsl:if>
		<xsl:apply-templates select="lsr:Address" mode="hode"/>
	</xsl:template>
	<xsl:template match="lsr:Animal" mode="hode">
		<div>
			<xsl:if test="lsr:Name"><b>Navn</b>:&#160;<xsl:value-of select="lsr:Name"/>&#160;</xsl:if>
			<xsl:if test="lsr:Species"><b>Art</b>:&#160;<xsl:value-of select="lsr:Species"/>&#160;</xsl:if>
			<xsl:if test="lsr:NameOwner"><b>Eier</b>:&#160;<xsl:value-of select="lsr:NameOwner"/>&#160;</xsl:if>
		</div>
	</xsl:template>
	<xsl:template match="lsr:Material" mode="hode">
		<div>
			<xsl:if test="lsr:Name"><b>Beskrivelse</b>:&#160;<xsl:value-of select="lsr:InvMaterial"/>&#160;</xsl:if>
		</div>
	</xsl:template>
	<xsl:template match="lsr:HCPerson" mode="hode">
		<div>
			<xsl:value-of select="lsr:Name"/>
			<div class="NoPrint">,</div>&#160;</div>
	</xsl:template>
	<xsl:template match="lsr:HCP" mode="hode">
		<xsl:apply-templates select="lsr:Inst" mode="hode"/>
		<xsl:apply-templates select="lsr:HCProf" mode="hode"/>
		<xsl:apply-templates select="lsr:Address" mode="hode"/>
	</xsl:template>
	<xsl:template match="lsr:Inst" mode="hode">
		<xsl:apply-templates select="lsr:HCPerson" mode="hode"/>
		<div>
			<xsl:value-of select="lsr:Name"/>
		</div>
		<xsl:for-each select="lsr:Dept">
			<div>
				<div class="NoPrint">-&#160;</div>
				<xsl:value-of select="lsr:Name"/>&#160;</div>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="lsr:HCProf" mode="hode">
		<div>
			<xsl:for-each select="lsr:Type">
				<xsl:call-template name="k-9060"/>
			</xsl:for-each>&#160;<xsl:value-of select="lsr:Name"/>
		</div>
	</xsl:template>
	<xsl:template match="lsr:CopyDest" mode="hode">
		<xsl:apply-templates select="lsr:HCP" mode="hode"/>
	</xsl:template>
	<xsl:template match="lsr:Address" mode="hode">
		<xsl:if test="lsr:Type and (lsr:StreetAdr or lsr:PostalCode or lsr:City or lsr:CityDistr)">
			<div class="NoPrint">&#160;<b>
				<xsl:for-each select="lsr:Type">
					<xsl:call-template name="k-3401"/>
				</xsl:for-each>:&#160;</b>
			</div>
		</xsl:if>
		<xsl:if test="lsr:StreetAdr">
			<div>
				<xsl:value-of select="lsr:StreetAdr"/>
			</div>
		</xsl:if>
		<xsl:if test="lsr:PostalCode or lsr:City">
			<xsl:if test="lsr:StreetAdr">
				<div class="NoPrint">,</div>
			</xsl:if>
			<div>
				<xsl:value-of select="lsr:PostalCode"/>&#160;<xsl:value-of select="lsr:City"/>
			</div>
		</xsl:if>
		<xsl:for-each select="lsr:CityDistr">
			<div class="NoPrint">,</div>
			<div>
				<xsl:call-template name="k-3403"/>
			</div>
		</xsl:for-each>
		<xsl:for-each select="lsr:County">
			<div class="NoPrint">,</div>
			<div>
				<xsl:call-template name="k-3402"/>
			</div>
		</xsl:for-each>
		<xsl:for-each select="lsr:Country">
			<div class="NoPrint">,</div>
			<div>
				<xsl:call-template name="k-9043"/>
			</div>
		</xsl:for-each>
		<xsl:for-each select="lsr:TeleAddress">
			<div class="NoPrint">&#160;</div>
			<xsl:apply-templates select="." mode="hode"/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="lsr:TeleAddress" mode="hode">
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
	<!-- Hoveddokument -->
	<xsl:template name="ResultBody">
		<div class="{$stil}">
			<xsl:variable name="position" select="position()"/>
			<xsl:variable name="color">
				<xsl:choose>
					<xsl:when test="lsr:ServType[@V='M' or @V='C' or @V='O']">red</xsl:when>
					<xsl:otherwise>black</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<!-- Tabell for svarrapport -->
			<h1>Svarrapport
				<xsl:for-each select="lsr:MsgDescr">
					<xsl:call-template name="k-8202"/>
				</xsl:for-each>
				<xsl:for-each select="lsr:ServType">&#160;-
					<font color="{$color}"><xsl:call-template name="k-7309"/></font>
				</xsl:for-each>
				<xsl:for-each select="lsr:Status">&#160;-
					<xsl:call-template name="k-7306"/>
				</xsl:for-each>
			</h1>
			<xsl:call-template name="FellesMeny">
				<xsl:with-param name="position" select="position()"/>
			</xsl:call-template>
			<br/>
			<xsl:variable name="id1">
				<xsl:value-of select="concat('ServReport',$position)"/>
			</xsl:variable>
			<h2 id="{$id1}">Meldingsinformasjon</h2>
			<table>
				<tbody>
					<xsl:apply-templates select=".">
						<xsl:with-param name="col" select="$std-col"/>
					</xsl:apply-templates>
				</tbody>
			</table>
			<!-- Tabell for analysert objekt -->
			<xsl:if test="//lsr:AnalysedSubject">
				<xsl:variable name="id2">
					<xsl:value-of select="concat('AnalysedSubject',$position)"/>
				</xsl:variable>
				<h2 id="{$id2}">Analysert materiale</h2>
				<table>
					<tbody>
						<xsl:for-each select="lsr:Patient/lsr:AnalysedSubject | lsr:Animal/lsr:AnalysedSubject | lsr:Material/lsr:AnalysedSubject">
							<xsl:apply-templates select=".">
								<xsl:with-param name="col" select="$std-col"/>
								<xsl:with-param name="pos" select="position()"/>
								<xsl:with-param name="last" select="last()"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Tabell for Undersøkelsesresultat -->
			<xsl:if test="//lsr:ResultItem">
				<xsl:variable name="id3">
					<xsl:value-of select="concat('ResultItem',$position)"/>
				</xsl:variable>
				<h2 id="{$id3}">Undersøkelsesresultat</h2> <!-- Denne tabellen kan bli tom om alle resultatene er merket med historikk. Antar det aldri skjer. -->
				<table>
					<tbody>
						<xsl:for-each select="//lsr:ResultItem[(lsr:ServType/@V != 'H' or not(lsr:ServType/@V)) and lsr:ResultItem[lsr:ServType/@V != 'H' or not(lsr:ServType/@V)]] | //lsr:ResultItem[(lsr:ServType/@V != 'H' or not(lsr:ServType/@V)) and not(../lsr:ServType/@V = 'H') and not(lsr:ResultItem)]"> <!-- Alle hovedsvar som ikke er merket med historikk som har minst et delsvar som ikke er merket historikk samt alle hovedsvar/delsvar som ikke er merket med historikk hvor forelder ikke er merket med historikk og som ikke selv har delsvar-->
							<xsl:variable name="slaaSammen"><!--  Variabel som er 'true' om hovedsvaret og dets første delsvar ikke har felles tabellelementer og dermed kan slås sammen - 'false' ellers.-->
								<xsl:variable name="overlapp">
									<xsl:if test="lsr:ResultItem[1]/lsr:Investigation or lsr:ResultItem[1]/lsr:TextResult/lsr:Heading/@V='GR'">
										<xsl:if test="lsr:Investigation or lsr:TextResult/lsr:Heading/@V='GR'">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="lsr:ResultItem[1]/lsr:TextResult or lsr:ResultItem[1]/lsr:Interval or lsr:ResultItem[1]/lsr:DateResult or lsr:ResultItem[1]/lsr:NumResult">
										<xsl:if test="lsr:TextResult or lsr:Interval or lsr:DateResult or lsr:NumResult">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="lsr:ResultItem[1]/lsr:IdResultItem">
										<xsl:if test="lsr:IdResultItem">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="lsr:ResultItem[1]/lsr:RefIdResultItem">RelServProv
										<xsl:if test="lsr:RefIdResultItem">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="lsr:ResultItem[1]/lsr:RefInterval">
										<xsl:if test="lsr:RefInterval">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="lsr:ResultItem[1]/lsr:InvDate or lsr:ResultItem[1]/lsr:StatusChangeDate or lsr:ResultItem[1]/lsr:DescrDate or lsr:ResultItem[1]/lsr:CounterSignDate or lsr:ResultItem[1]/lsr:MedicalValidationDate">
										<xsl:if test="lsr:InvDate or lsr:StatusChangeDate or lsr:DescrDate or lsr:CounterSignDate or lsr:MedicalValidationDate">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="lsr:ResultItem[1]/lsr:RelServProv">
										<xsl:if test="lsr:RelServProv">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="lsr:ResultItem[1]/lsr:Accredited or lsr:ResultItem[1]/lsr:StructuredInfo or lsr:ResultItem[1]/lsr:Investigation/lsr:Comment or lsr:ResultItem[1]/lsr:Investigation/lsr:Spec or lsr:ResultItem[1]/lsr:Comment or lsr:ResultItem[1]/lsr:DiagComment or lsr:ResultItem[1]/lsr:RefAnalysedSubject or lsr:ResultItem[1]/lsr:StatusInvestigation">
										<xsl:if test="lsr:Accredited or lsr:StructuredInfo or lsr:Investigation/lsr:Comment or lsr:Investigation/lsr:Spec or lsr:Comment or lsr:DiagComment or lsr:RefAnalysedSubject or lsr:StatusInvestigation">Ja</xsl:if>
									</xsl:if>
								</xsl:variable>
								<xsl:choose>
									  <xsl:when test="lsr:ResultItem and not(contains($overlapp,'Ja'))">true</xsl:when>
									<xsl:otherwise>false</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="forsteDelsvarSlaattSammen"><!-- Variabel som er 'true' om nåværende node er første delsvar som er slått sammen med sitt hovedsvar - 'false' ellers -->
								<xsl:variable name="overlappForelder">
									<xsl:if test="../lsr:Investigation or ../lsr:TextResult/lsr:Heading/@V='GR'">
										<xsl:if test="lsr:Investigation or lsr:TextResult/lsr:Heading/@V='GR'">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../lsr:TextResult or ../lsr:Interval or ../lsr:DateResult or ../lsr:NumResult">
										<xsl:if test="lsr:TextResult or lsr:Interval or lsr:DateResult or lsr:NumResult">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../lsr:IdResultItem">
										<xsl:if test="lsr:IdResultItem">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../lsr:RefIdResultItem">RelServProv
										<xsl:if test="lsr:RefIdResultItem">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../lsr:RefInterval">
										<xsl:if test="lsr:RefInterval">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../lsr:InvDate or ../lsr:StatusChangeDate or ../lsr:DescrDate or ../lsr:CounterSignDate or ../lsr:MedicalValidationDate">
										<xsl:if test="lsr:InvDate or lsr:StatusChangeDate or lsr:DescrDate or lsr:CounterSignDate or lsr:MedicalValidationDate">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../lsr:RelServProv">
										<xsl:if test="lsr:RelServProv">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../lsr:Accredited or ../lsr:StructuredInfo or ../lsr:Investigation/lsr:Comment or ../lsr:Investigation/lsr:Spec or ../lsr:Comment or ../lsr:DiagComment or ../lsr:RefAnalysedSubject or ../lsr:StatusInvestigation">
										<xsl:if test="lsr:Accredited or lsr:StructuredInfo or lsr:Investigation/lsr:Comment or lsr:Investigation/lsr:Spec or lsr:Comment or lsr:DiagComment or lsr:RefAnalysedSubject or lsr:StatusInvestigation">Ja</xsl:if>
									</xsl:if>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="local-name(..)='ResultItem' and not(preceding-sibling::*[1][self::lsr:ResultItem]) and not(contains($overlappForelder,'Ja'))">true</xsl:when>
									<xsl:otherwise>false</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:if test="position()=1">
								<xsl:call-template name="skrivUtUndersokelseOverskrift"/>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="$forsteDelsvarSlaattSammen='true'"></xsl:when>
								<xsl:otherwise><xsl:apply-templates select="."><xsl:with-param name="slaaSammen" select="$slaaSammen"/></xsl:apply-templates></xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Tabell for Historiske Undersøkelsesresultat -->
			<xsl:if test="//lsr:ResultItem[lsr:ServType/@V = 'H']">
				<xsl:variable name="id3">
					<xsl:value-of select="concat('ResultItem',$position)"/>
				</xsl:variable>
				<h2 id="{$id3}">Undersøkelsesresultat&#160;(<font color="red">historikk</font>)</h2>
				<table>
					<tbody>
						<xsl:for-each select="//lsr:ResultItem[lsr:ServType/@V = 'H'] | //lsr:ResultItem[lsr:ServType/@V = 'H']/lsr:ResultItem | //lsr:ResultItem[lsr:ResultItem[lsr:ServType/@V = 'H']]"> <!-- Alle hovedsvar/delsvar merket med historikk, alle delsvar av hovedsvar merket med historikk, samt alle hovedsvar som har delsvar merket med historikk -->
							<xsl:variable name="slaaSammen"><!--  Variabel som er 'true' om hovedsvaret og dets første delsvar ikke har felles tabellelementer og dermed kan slås sammen - 'false' ellers.-->
								<xsl:variable name="overlapp">
									<xsl:if test="lsr:ResultItem[1]/lsr:Investigation or lsr:ResultItem[1]/lsr:TextResult/lsr:Heading/@V='GR'">
										<xsl:if test="lsr:Investigation or lsr:TextResult/lsr:Heading/@V='GR'">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="lsr:ResultItem[1]/lsr:TextResult or lsr:ResultItem[1]/lsr:Interval or lsr:ResultItem[1]/lsr:DateResult or lsr:ResultItem[1]/lsr:NumResult">
										<xsl:if test="lsr:TextResult or lsr:Interval or lsr:DateResult or lsr:NumResult">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="lsr:ResultItem[1]/lsr:IdResultItem">
										<xsl:if test="lsr:IdResultItem">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="lsr:ResultItem[1]/lsr:RefIdResultItem">RelServProv
										<xsl:if test="lsr:RefIdResultItem">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="lsr:ResultItem[1]/lsr:RefInterval">
										<xsl:if test="lsr:RefInterval">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="lsr:ResultItem[1]/lsr:InvDate or lsr:ResultItem[1]/lsr:StatusChangeDate or lsr:ResultItem[1]/lsr:DescrDate or lsr:ResultItem[1]/lsr:CounterSignDate or lsr:ResultItem[1]/lsr:MedicalValidationDate">
										<xsl:if test="lsr:InvDate or lsr:StatusChangeDate or lsr:DescrDate or lsr:CounterSignDate or lsr:MedicalValidationDate">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="lsr:ResultItem[1]/lsr:RelServProv">
										<xsl:if test="lsr:RelServProv">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="lsr:ResultItem[1]/lsr:Accredited or lsr:ResultItem[1]/lsr:StructuredInfo or lsr:ResultItem[1]/lsr:Investigation/lsr:Comment or lsr:ResultItem[1]/lsr:Investigation/lsr:Spec or lsr:ResultItem[1]/lsr:Comment or lsr:ResultItem[1]/lsr:DiagComment or lsr:ResultItem[1]/lsr:RefAnalysedSubject or lsr:ResultItem[1]/lsr:StatusInvestigation">
										<xsl:if test="lsr:Accredited or lsr:StructuredInfo or lsr:Investigation/lsr:Comment or lsr:Investigation/lsr:Spec or lsr:Comment or lsr:DiagComment or lsr:RefAnalysedSubject or lsr:StatusInvestigation">Ja</xsl:if>
									</xsl:if>
								</xsl:variable>
								<xsl:choose>
									  <xsl:when test="lsr:ResultItem and not(contains($overlapp,'Ja'))">true</xsl:when>
									<xsl:otherwise>false</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="forsteDelsvarSlaattSammen"><!-- Variabel som er 'true' om nåværende node er første delsvar som er slått sammen med sitt hovedsvar - 'false' ellers -->
								<xsl:variable name="overlappForelder">
									<xsl:if test="../lsr:Investigation or ../lsr:TextResult/lsr:Heading/@V='GR'">
										<xsl:if test="lsr:Investigation or lsr:TextResult/lsr:Heading/@V='GR'">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../lsr:TextResult or ../lsr:Interval or ../lsr:DateResult or ../lsr:NumResult">
										<xsl:if test="lsr:TextResult or lsr:Interval or lsr:DateResult or lsr:NumResult">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../lsr:IdResultItem">
										<xsl:if test="lsr:IdResultItem">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../lsr:RefIdResultItem">RelServProv
										<xsl:if test="lsr:RefIdResultItem">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../lsr:RefInterval">
										<xsl:if test="lsr:RefInterval">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../lsr:InvDate or ../lsr:StatusChangeDate or ../lsr:DescrDate or ../lsr:CounterSignDate or ../lsr:MedicalValidationDate">
										<xsl:if test="lsr:InvDate or lsr:StatusChangeDate or lsr:DescrDate or lsr:CounterSignDate or lsr:MedicalValidationDate">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../lsr:RelServProv">
										<xsl:if test="lsr:RelServProv">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../lsr:Accredited or ../lsr:StructuredInfo or ../lsr:Investigation/lsr:Comment or ../lsr:Investigation/lsr:Spec or ../lsr:Comment or ../lsr:DiagComment or ../lsr:RefAnalysedSubject or ../lsr:StatusInvestigation">
										<xsl:if test="lsr:Accredited or lsr:StructuredInfo or lsr:Investigation/lsr:Comment or lsr:Investigation/lsr:Spec or lsr:Comment or lsr:DiagComment or lsr:RefAnalysedSubject or lsr:StatusInvestigation">Ja</xsl:if>
									</xsl:if>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="local-name(..)='ResultItem' and not(preceding-sibling::*[1][self::lsr:ResultItem]) and not(contains($overlappForelder,'Ja'))">true</xsl:when>
									<xsl:otherwise>false</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:if test="position()=1">
								<xsl:call-template name="skrivUtUndersokelseOverskrift"/>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="$forsteDelsvarSlaattSammen='true'"></xsl:when>
								<xsl:otherwise><xsl:apply-templates select="."><xsl:with-param name="slaaSammen" select="$slaaSammen"/></xsl:apply-templates></xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
			<!-- Tabell for Strukturert resultat -->
			<xsl:if test="//lsr:ResultItem[lsr:StructuredInfo]">
				<xsl:variable name="id03">
					<xsl:value-of select="concat('StructuredInfo',$position)"/>
				</xsl:variable>
				<xsl:for-each select="//lsr:ResultItem[lsr:StructuredInfo]">
					<h2 id="{$id03}">Strukturert resultat
						<xsl:if test="last()!=1">
							<xsl:value-of select="count(//lsr:ResultItem[lsr:StructuredInfo])-count(following-sibling::lsr:ResultItem[lsr:StructuredInfo])-count(parent::lsr:ResultItem/following-sibling::lsr:ResultItem[lsr:StructuredInfo])-count(child::lsr:ResultItem[lsr:StructuredInfo])"/>
						</xsl:if>
					</h2>
					<xsl:apply-templates select="." mode="StructuredInfo"/>
				</xsl:for-each>
			</xsl:if>
			<!-- Tabell for oprinnelig rekvisisjon -->
			<xsl:for-each select="lsr:ServReq">
				<xsl:variable name="id4">
					<xsl:value-of select="concat('ServReq',$position)"/>
				</xsl:variable>
				<h2 id="{$id4}">Opprinnelig rekvisisjon
					<xsl:for-each select="lsr:MsgDescr">
						<xsl:call-template name="k-8202"/>
					</xsl:for-each>
					<xsl:for-each select="lsr:ServType">&#160;-
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
			<xsl:for-each select="lsr:Patient">
				<xsl:if test="lsr:BasisForHealthServices or lsr:Sex or lsr:DateOfBirth or lsr:DateOfDeath or lsr:AdmLocation or lsr:AdditionalId or lsr:InfItem or lsr:Patient">
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
			<xsl:for-each select="lsr:Animal">
				<xsl:if test="lsr:Sex or lsr:Animal">
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
					<xsl:for-each select="lsr:ServProvider | lsr:Requester | lsr:PaymentResponsible | lsr:CopyDest | lsr:RelServProv | .//lsr:RelServProv[descendant::lsr:Id] | .//lsr:ResponsibleHcp | lsr:Patient/lsr:AdmLocation">
						<xsl:variable name="historikk">
							<xsl:choose>
								<xsl:when test="ancestor::lsr:ResultItem[lsr:ServType/@V='H']">true</xsl:when>
								<xsl:otherwise>false</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:apply-templates select=".">
							<xsl:with-param name="col" select="$std-col"/>
							<xsl:with-param name="historikk" select="$historikk"/>
						</xsl:apply-templates>
					</xsl:for-each>
				</tbody>
			</table>
			<!-- Tabell for referert dokument -->
			<xsl:if test="lsr:RefDoc">
				<xsl:variable name="id8">
					<xsl:value-of select="concat('RefDoc',$position)"/>
				</xsl:variable>
				<h2 id="{$id8}">Referert dokument</h2>
				<table>
					<tbody>
						<xsl:for-each select="lsr:RefDoc">
							<xsl:apply-templates select=".">
								<xsl:with-param name="col" select="$std-col"/>
							</xsl:apply-templates>
						</xsl:for-each>
					</tbody>
				</table>
			</xsl:if>
		</div>
	</xsl:template>
	<!-- Meldingshodet - Dokumentopplysninger -->
	<xsl:template name="Footer">
		<div class="{$stil}">
			<h2 style="margin-top:0px;">Dokumentinformasjon</h2>
			<table>
				<tbody>
					<tr>
						<th>Melding sendt</th>
						<td width="{$std-td}px">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../lsr:GenDate/@V"/>
							</xsl:call-template>
						</td>
						<th>Avsenders id</th>
						<td width="{$std-td}px">
							<xsl:value-of select="lsr:ServProvId"/>
						</td>
						<th>Meldingsid</th>
						<td>
							<xsl:value-of select="../lsr:MsgId"/>
						</td>
					</tr>
					<tr>
						<th>Visningsversjon</th>
						<td><xsl:value-of select="$versjon"/></td>
					</tr>
				</tbody>
			</table>
		</div>
	</xsl:template>
	<!-- Klikkbar horisontal meny som leder lenger ned i dokumentet -->
	<xsl:template name="FellesMeny">
		<xsl:param name="position"/>
		<div id="FellesMeny" class="FellesMeny">
			<ul>
				<li>
					<xsl:variable name="temp1" select="concat('ServReport',$position)"/>
					<a href="#{$temp1}">Meldingsinformasjon</a>
				</li>
				<xsl:if test=".//lsr:Patient/lsr:AnalysedSubject or .//lsr:Animal/lsr:AnalysedSubject or .//lsr:Material/lsr:AnalysedSubject">
					<li>
						<xsl:variable name="temp2" select="concat('AnalysedSubject',$position)"/>
						<a href="#{$temp2}">Analysert materiale</a>
					</li>
				</xsl:if>
				<xsl:if test=".//lsr:ResultItem">
					<li>
						<xsl:variable name="temp3" select="concat('ResultItem',$position)"/>
						<a href="#{$temp3}">Undersøkelsesresultat</a>
					</li>
				</xsl:if>
				<xsl:if test=".//lsr:ResultItem[lsr:StructuredInfo]">
					<li>
						<xsl:variable name="temp03" select="concat('StructuredInfo',$position)"/>
						<a href="#{$temp03}">Strukturert resultat</a>
					</li>
				</xsl:if>
				<xsl:if test=".//lsr:ServReq">
					<li>
						<xsl:variable name="temp4" select="concat('ServReq',$position)"/>
						<a href="#{$temp4}">Opprinnelig rekvisisjon</a>
					</li>
				</xsl:if>
				<xsl:if test=".//lsr:Patient/lsr:BasisForHealthServices or .//lsr:Patient/lsr:Sex or .//lsr:Patient/lsr:DateOfBirth or .//lsr:Patient/lsr:DateOfDeath or .//lsr:Patient/lsr:AdmLocation or .//lsr:Patient/lsr:AdditionalId or .//lsr:Patient/lsr:InfItem or .//lsr:Patient/lsr:Patient">
					<li>
						<xsl:variable name="temp5" select="concat('Patient',$position)"/>
						<a href="#{$temp5}">Pasient</a>
					</li>
				</xsl:if>
				<xsl:if test=".//lsr:Animal/lsr:Sex or .//lsr:Animal/lsr:Animal">
					<li>
						<xsl:variable name="temp6" select="concat('Animal',$position)"/>
						<a href="#{$temp6}">Undersøkelsesdyr</a>
					</li>
				</xsl:if>
				<xsl:if test=".//lsr:ServProvider | .//lsr:Requester | .//lsr:PaymentResponsible | .//lsr:CopyDest | lsr:RelServProv | .//lsr:RelServProv[descendant::lsr:Id] | .//lsr:ResponsibleHcp | .//lsr:Patient/lsr:AdmLocation">
					<li>
						<xsl:variable name="temp7" select="concat('HCP',$position)"/>
						<a href="#{$temp7}">Helsetjenesteenheter</a>
					</li>
				</xsl:if>
				<xsl:if test=".//lsr:RefDoc">
					<li>
						<xsl:variable name="temp8" select="concat('RefDoc',$position)"/>
						<a href="#{$temp8}">Vedlegg</a>
					</li>
				</xsl:if>
			</ul>
		</div>
	</xsl:template>
	<!-- Visning av Svarrapport -->
	<xsl:template match="lsr:ServReport">
		<xsl:param name="col"/>
		<tr>
			<th>Utstedt-dato</th>
			<td width="{((($col)-2)*number(not(lsr:ApprDate | lsr:CancellationCode))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lsr:ApprDate | lsr:CancellationCode))+1}">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="lsr:IssueDate/@V"/>
				</xsl:call-template>
			</td>
			<xsl:if test="lsr:ApprDate">
				<th>Godkjent-dato</th>
				<td width="{((($col)-2-count(lsr:IssueDate)*2)*number(not(lsr:CancellationCode))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:IssueDate)*2)*number(not(lsr:CancellationCode))+1}">
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="lsr:ApprDate/@V"/>
					</xsl:call-template>
				</td>
			</xsl:if>
			<xsl:if test="lsr:CancellationCode">
				<th>Årsak til kansellering</th>
				<td colspan="{($col)-1-count(lsr:IssueDate | lsr:ApprDate)*2}">
					<xsl:for-each select="lsr:CancellationCode">
						<xsl:call-template name="k-dummy"/>
					</xsl:for-each>
				</td>
			</xsl:if>
		</tr>
		<xsl:if test="lsr:Comment or lsr:CodedComment">
			<tr>
				<th>Kommentar til svarrapporten</th>
				<td colspan="{($col)-1}">
					<xsl:for-each select="lsr:Comment">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="."/>
						</xsl:call-template>&#160;
					</xsl:for-each>
					<xsl:for-each select="lsr:CodedComment[contains(@S,'8272')]">
						<xsl:if test="position()=1">
							<span class="strong">Anbefaler ny undersøkelse:&#160;</span>
						</xsl:if>
						<xsl:call-template name="k-8272"/>
						<xsl:choose>
							<xsl:when test="position()!=last()">,&#160;</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
					<xsl:for-each select="lsr:CodedComment[contains(@S,'8273')]">
						<xsl:if test="position()=1">
							<span class="strong">Hastegrad:&#160;</span>
						</xsl:if>
						<xsl:call-template name="k-8273"/>&#160;
					</xsl:for-each>
					<xsl:for-each select="lsr:CodedComment[not(contains(@S,'8272')) and not(contains(@S,'8273'))]">
						<xsl:choose>
							<xsl:when test="contains(@S,'8269')">
								<xsl:call-template name="k-8269"/>&#160;
							</xsl:when>
							<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
	<!-- Visning av Opprinnelig rekvisisjon -->
	<xsl:template match="lsr:ServReq">
		<xsl:param name="col"/>
		<xsl:if test="lsr:IssueDate or lsr:ReceiptDate or lsr:RequestedPrioReport or lsr:PaymentCat or lsr:Reservation">
			<tr>
				<xsl:if test="lsr:IssueDate">
					<th>Utstedt-dato</th>
					<td width="{((($col)-2)*number(not(lsr:ReceiptDate | lsr:RequestedPrioReport | lsr:PaymentCat | lsr:Reservation))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lsr:ReceiptDate | lsr:RequestedPrioReport | lsr:PaymentCat | lsr:Reservation))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="lsr:IssueDate/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="lsr:ReceiptDate">
					<th>Mottatt-dato</th>
					<td width="{((($col)-2-count(lsr:IssueDate)*2)*number(not(lsr:RequestedPrioReport | lsr:PaymentCat | lsr:Reservation))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:IssueDate)*2)*number(not(lsr:RequestedPrioReport | lsr:PaymentCat | lsr:Reservation))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="lsr:ReceiptDate/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="lsr:RequestedPrioReport">
					<th>Ønsket prioritet</th>
					<td width="{((($col)-2-count(lsr:IssueDate | lsr:ReceiptDate)*2)*number(not(lsr:PaymentCat | lsr:Reservation))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:IssueDate | lsr:ReceiptDate)*2)*number(not(lsr:PaymentCat | lsr:Reservation))+1}">
						<xsl:for-each select="lsr:RequestedPrioReport">
							<xsl:call-template name="k-7303"/>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="lsr:PaymentCat">
					<th>Betalingskategori</th>
					<td width="{((($col)-2-count(lsr:IssueDate | lsr:ReceiptDate | lsr:RequestedPrioReport)*2)*number(not(lsr:Reservation))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:IssueDate | lsr:ReceiptDate | lsr:RequestedPrioReport)*2)*number(not(lsr:Reservation))+1}">
						<xsl:for-each select="lsr:PaymentCat">
							<xsl:call-template name="k-4101"/>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="lsr:Reservation">
					<th>Pasientens reservasjoner</th>
					<td colspan="{($col)-1-count(lsr:IssueDate | lsr:ReceiptDate | lsr:RequestedPrioReport | lsr:PaymentCat)*2}">
						<xsl:for-each select="lsr:Reservation">
							<div>
								<xsl:call-template name="k-3108"/>
							</div>
						</xsl:for-each>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="lsr:ReqComment">
			<tr>
				<th>Rekvirentens kommentar</th>
				<td colspan="{($col)-1}">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="lsr:ReqComment"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="lsr:ReasonAsText">
			<tr>
				<th colspan="{$col}" class="h3">Begrunnelser</th>
			</tr>
			<xsl:apply-templates select="lsr:ReasonAsText">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:if>
		<xsl:if test="lsr:Comment">
			<tr>
				<th colspan="{$col}" class="h3">Kommentarer</th>
			</tr>
			<xsl:apply-templates select="lsr:Comment">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	<!-- Visning av Kommentar til rekvisisjon -->
	<xsl:template match="lsr:Comment">
		<xsl:param name="col"/>
		<xsl:if test="lsr:Heading or lsr:TextResultValue or lsr:TextCode">
			<tr>
				<th>
					<xsl:choose>
						<xsl:when test="lsr:Heading">
							<xsl:for-each select="lsr:Heading">
								<xsl:call-template name="k-8234"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:when test="contains(lsr:TextCode/@S,'8274')">Anbefaling om supplerende undersøkelse</xsl:when>
						<xsl:otherwise>Generell</xsl:otherwise>
					</xsl:choose>
				</th>
				<td colspan="{($col)-1}">
					<xsl:for-each select="lsr:TextResultValue">
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
					<xsl:for-each select="lsr:TextCode">
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
	<!-- Visning av Begrunnelse for rekvisisjon -->
	<xsl:template match="lsr:ReasonAsText">
		<xsl:param name="col"/>
		<xsl:if test="lsr:Heading or lsr:TextResultValue">
			<tr>
				<th>
					<xsl:for-each select="lsr:Heading">
						<xsl:call-template name="k-8231"/>
					</xsl:for-each>
				</th>
				<td colspan="{($col)-1}">
					<xsl:for-each select="lsr:TextResultValue">
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
	<!-- Visning av Øvrig pasientinformasjon -->
	<xsl:template match="lsr:Patient">
		<xsl:param name="col"/>
		<tr>
			<th>Navn&#160;<xsl:if test="lsr:Relation and local-name(..)='Patient'">-&#160;relasjon:&#160;<xsl:for-each select="lsr:Relation"><xsl:call-template name="k-8238"/></xsl:for-each></xsl:if></th>
			<td width="{$std-td}px">
				<xsl:value-of select="lsr:Name"/>
			</td>
			<th>
				<xsl:for-each select="lsr:TypeOffId">
					<xsl:call-template name="k-8116"/>
				</xsl:for-each>
			</th>
			<td width="{((($col)-2-count(lsr:Name)*2)*number(not(lsr:Sex | lsr:DateOfBirth | lsr:DateOfDeath))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:Name)*2)*number(not(lsr:Sex | lsr:DateOfBirth | lsr:DateOfDeath))+1}">
				<xsl:value-of select="lsr:OffId"/>
			</td>
			<xsl:if test="lsr:Sex">
				<th>Kjønn</th>
				<td width="{((($col)-2-count(lsr:Name | lsr:OffId)*2)*number(not(lsr:DateOfBirth | lsr:DateOfDeath))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:Name | lsr:OffId)*2)*number(not(lsr:DateOfBirth | lsr:DateOfDeath))+1}">
					<xsl:for-each select="lsr:Sex">
						<xsl:call-template name="k-3101"/>
					</xsl:for-each>
				</td>
			</xsl:if>
			<xsl:if test="lsr:DateOfBirth">
				<th>Fødselsdato</th>
				<td width="{((($col)-2-count(lsr:Name | lsr:OffId | lsr:Sex)*2)*number(not(lsr:DateOfDeath))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:Name | lsr:OffId | lsr:Sex)*2)*number(not(lsr:DateOfDeath))+1}">
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="lsr:DateOfBirth/@V"/>
					</xsl:call-template>
				</td>
			</xsl:if>
			<xsl:if test="lsr:DateOfDeath">
				<th>Dødsdato</th>
				<td colspan="{(($col)-1-count(lsr:Name | lsr:OffId | lsr:Sex | lsr:DateOfBirth)*2)}">
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="lsr:DateOfDeath/@V"/>
					</xsl:call-template>
				</td>
			</xsl:if>
		</tr>
		<xsl:for-each select="lsr:Address">
			<xsl:variable name="antall-tel" select="count(lsr:TeleAddress)"/>
			<tr>
				<xsl:apply-templates select="lsr:TeleAddress">
					<xsl:with-param name="col" select="(($col)-1)*number(not(lsr:Type and (lsr:PostalCode or lsr:City)))+1"/>
				</xsl:apply-templates>
				<xsl:if test="lsr:Type and (lsr:PostalCode or lsr:City)">
					<xsl:apply-templates select=".">
						<xsl:with-param name="col" select="($col)-1-($antall-tel)*2"/>
					</xsl:apply-templates>
				</xsl:if>
			</tr>
		</xsl:for-each>
		<xsl:if test="lsr:AdditionalId or lsr:BasisForHealthServices">
			<xsl:variable name="antall-id" select="count(lsr:AdditionalId)"/>
			<tr>
				<xsl:choose>
					<xsl:when test="lsr:AdditionalId and lsr:BasisForHealthServices">
						<th colspan="2">Andre pasient-identifikatorer</th>
						<xsl:for-each select="lsr:AdditionalId">
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
							<xsl:for-each select="lsr:BasisForHealthServices">
								<xsl:call-template name="k-8246"/>
							</xsl:for-each>
						</td>
					</xsl:when>
					<xsl:when test="lsr:AdditionalId and not(lsr:BasisForHealthServices)">
						<th colspan="2">Andre pasient-identifikatorer</th>
						<xsl:for-each select="lsr:AdditionalId">
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
							<xsl:for-each select="lsr:BasisForHealthServices">
								<xsl:call-template name="k-8246"/>
							</xsl:for-each>
						</td>
					</xsl:otherwise>
				</xsl:choose>
			</tr>
		</xsl:if>
		<xsl:for-each select="lsr:AdmLocation">
			<tr>
				<th colspan="{$col}" class="h3">
					Opphold
				</th>
			</tr>
			<tr>
				<th>Institusjon</th>
				<td width="{((($col)-2)*number(not(lsr:AdmCat | lsr:StartDateTime | lsr:EndDateTime))+1)*$std-td}px" colspan="{(($col)-4)*number(not(lsr:AdmCat | lsr:StartDateTime | lsr:EndDateTime))+3}">
					<!-- Gir her boksen en default kolonnebredde på 3 mot normalt 1 -->
					<xsl:value-of select="lsr:Location/lsr:Inst/lsr:Name"/>
					<xsl:if test="lsr:Location/lsr:Inst/lsr:Dept/lsr:Name">
						<xsl:for-each select="lsr:Location/lsr:Inst/lsr:Dept">,&#160;<xsl:value-of select="lsr:Name"/>
						</xsl:for-each>
					</xsl:if>
					<xsl:for-each select="lsr:Location/lsr:SubLocation">,&#160;<xsl:for-each select="lsr:Type"><xsl:call-template name="k-8242"/></xsl:for-each>:&#160;<xsl:value-of select="lsr:Place"/>
					</xsl:for-each>
				</td>
				<xsl:if test="lsr:AdmCat">
					<th>Type&#160;tjeneste&#160;</th>
					<td width="{((($col)-6)*number(not(lsr:StartDateTime | lsr:EndDateTime))+1)*$std-td}px" colspan="{(($col)-6)*number(not(lsr:StartDateTime | lsr:EndDateTime))+1}">
						<xsl:for-each select="lsr:AdmCat">
							<xsl:call-template name="k-8240"/>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="lsr:StartDateTime">
					<th>Innlagt&#160;dato&#160;</th>
					<td width="{((($col)-6-count(lsr:AdmCat)*2)*number(not(lsr:EndDateTime))+1)*$std-td}px" colspan="{(($col)-6-count(lsr:AdmCat)*2)*number(not(lsr:EndDateTime))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="lsr:StartDateTime/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="lsr:EndDateTime">
					<th>Utskrevet&#160;dato&#160;</th>
					<td colspan="{(($col)-5-count(lsr:AdmCat | lsr:StartDateTime)*2)}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="lsr:EndDateTime/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="lsr:Patient | lsr:InfItem">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Øvrig informasjon om dyret -->
	<xsl:template match="lsr:Animal">
		<xsl:param name="col"/>
		<tr>
			<xsl:if test="lsr:NameOwner">
				<th>Eier&#160;</th>
				<td width="{((($col)-2)*number(not(lsr:Name | lsr:Sex | lsr:Species))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lsr:Name | lsr:Sex | lsr:Species))+1}">
					<xsl:value-of select="lsr:NameOwner"/>
				</td>
			</xsl:if>
			<xsl:if test="lsr:Name">
				<th>Navn&#160;
					<xsl:if test="local-name(..)='Animal'">
						-&#160;relasjon:&#160;<xsl:for-each select="lsr:Relation"><xsl:call-template name="k-8238"/></xsl:for-each>
					</xsl:if>
				</th>
				<td width="{((($col)-2-count(lsr:NameOwner)*2)*number(not(lsr:Sex | lsr:Species))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:NameOwner)*2)*number(not(lsr:Sex | lsr:Species))+1}">
					<xsl:value-of select="lsr:Name"/>
				</td>
			</xsl:if>
			<xsl:if test="lsr:Sex">
				<th>Kjønn</th>
				<td width="{((($col)-2-count(lsr:NameOwner | lsr:Name)*2)*number(not(lsr:Species))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:NameOwner | lsr:Name)*2)*number(not(lsr:Species))+1}">
					<xsl:for-each select="lsr:Sex">
						<xsl:call-template name="k-3101"/>
					</xsl:for-each>
				</td>
			</xsl:if>
			<xsl:if test="lsr:Species">
				<th>Art</th>
				<td colspan="{($col)-1-count(lsr:NameOwner | lsr:Name | lsr:Sex)*2}">
					<xsl:value-of select="lsr:Species"/>
				</td>
			</xsl:if>
		</tr>
		<xsl:if test="lsr:Animal">
			<xsl:apply-templates select="lsr:Animal">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	<!-- Visning av Analysert objekt -->
	<xsl:template match="lsr:AnalysedSubject">
		<xsl:param name="col"/>
		<xsl:param name="pos"/>
		<xsl:param name="last"/>
		<xsl:if test="lsr:Type or lsr:TypeCoded or lsr:IdByServProvider or lsr:CollectedSample or lsr:CollectedStudyProduct">
			<tr>
				<xsl:if test="lsr:Type or lsr:TypeCoded"><!-- Enten Type eller TypeCoded må oppgis - jfr. standard HIS 80822:2014 -->
					<th>Type&#160;materiale<xsl:if test="$last!=1">&#160;<xsl:value-of select="$pos"/></xsl:if>
						<xsl:for-each select="lsr:ServType">
							-&#160;<xsl:call-template name="k-7309"/>
						</xsl:for-each>
					</th>
					<td width="{((($col)-2)*number(not(lsr:IdByServProvider | lsr:CollectedSample | lsr:CollectedStudyProduct))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lsr:IdByServProvider | lsr:CollectedSample | lsr:CollectedStudyProduct))+1}">
					<!--Kommentar til en tilsynelatende for lang kolonnebredde: CollectedSample og CollectedStudyProduct er innenfor en choice -->
						<xsl:choose>
							<xsl:when test="lsr:Type">
								<xsl:value-of select="lsr:Type"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="lsr:TypeCoded">
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
				<xsl:if test="lsr:IdByServProvider">
					<th>Avsenders&#160;id</th>
					<td width="{((($col)-2-number(boolean(../lsr:Type or ../lsr:TypeCoded))*2)*number(not(lsr:CollectedSample | lsr:CollectedStudyProduct))+1)*$std-td}px" colspan="{(($col)-2-number(boolean(../lsr:Type or ../lsr:TypeCoded))*2)*number(not(lsr:CollectedSample | lsr:CollectedStudyProduct))+1}">
						<xsl:value-of select="lsr:IdByServProvider"/>
					</td>
				</xsl:if>
				<xsl:for-each select="lsr:CollectedSample">
					<xsl:if test="lsr:CollectedDate">
						<th>Dato&#160;prøvetakning</th>
						<td width="{((($col)-2-number(boolean(../lsr:Type or ../lsr:TypeCoded))*2-count(../lsr:IdByServProvider)*2)*number(not(lsr:CollectorComment | lsr:CollectorCommentCoded | lsr:Logistics))+1)*$std-td}px" colspan="{(($col)-2-number(boolean(../lsr:Type or ../lsr:TypeCoded))*2-count(../lsr:IdByServProvider)*2)*number(not(lsr:CollectorComment | lsr:CollectorCommentCoded | lsr:Logistics))+1}">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="lsr:CollectedDate/@V"/>
							</xsl:call-template>
						</td>
					</xsl:if>
					<xsl:if test="lsr:Logistics">
						<th>Forsendelsesmåte</th>
						<td width="{((($col)-2-number(boolean(../lsr:Type or ../lsr:TypeCoded))*2-count(../lsr:IdByServProvider | lsr:CollectedDate)*2)*number(not(lsr:CollectorComment | lsr:CollectorCommentCoded))+1)*$std-td}px" colspan="{(($col)-2-number(boolean(../lsr:Type or ../lsr:TypeCoded))*2-count(../lsr:IdByServProvider | lsr:CollectedDate)*2)*number(not(lsr:CollectorComment | lsr:CollectorCommentCoded))+1}">
							<xsl:value-of select="lsr:Logistics"/>
						</td>
					</xsl:if>
					<xsl:if test="lsr:CollectorComment or lsr:CollectorCommentCoded">
						<th>Prøvetakers&#160;kommentar</th>
						<td colspan="{($col)-1-number(boolean(../lsr:Type or ../lsr:TypeCoded))*2-count(../lsr:IdByServProvider | lsr:CollectedDate | lsr:Logistics)*2}">
							<xsl:if test="lsr:CollectorComment">
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="lsr:CollectorComment"/>
								</xsl:call-template>&#160;
							</xsl:if>
							<xsl:for-each select="lsr:CollectorCommentCoded">
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
				<xsl:for-each select="lsr:CollectedStudyProduct">
					<xsl:if test="lsr:Type">
						<th>Type&#160;analyseprodukt</th>
						<td width="{((($col)-2-number(boolean(../lsr:Type or ../lsr:TypeCoded))*2-count(../lsr:IdByServProvider)*2)*number(not(lsr:ProducedDate | lsr:RefRelatedProd))+1)*$std-td}px" colspan="{(($col)-2-number(boolean(../lsr:Type or ../lsr:TypeCoded))*2-count(../lsr:IdByServProvider)*2)*number(not(lsr:ProducedDate | lsr:RefRelatedProd))+1}">
							<xsl:value-of select="lsr:Type"/>
						</td>
					</xsl:if>
					<xsl:if test="lsr:ProducedDate">
						<th>Dato&#160;prøvetakning</th>
						<td width="{((($col)-2-number(boolean(../lsr:Type or ../lsr:TypeCoded))*2-count(../lsr:IdByServProvider | lsr:Type)*2)*number(not(lsr:RefRelatedProd))+1)*$std-td}px" colspan="{(($col)-2-number(boolean(../lsr:Type or ../lsr:TypeCoded))*2-count(../lsr:IdByServProvider | lsr:Type)*2)*number(not(lsr:RefRelatedProd))+1}">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="lsr:ProducedDate/@V"/>
							</xsl:call-template>
						</td>
					</xsl:if>
					<xsl:if test="lsr:RefRelatedProd">
						<th>Referanse</th>
						<td colspan="{($col)-1-number(boolean(../lsr:Type or ../lsr:TypeCoded))*2-count(../lsr:IdByServProvider | lsr:Type | lsr:ProducedDate)*2}">
							<xsl:value-of select="lsr:RefRelatedProd"/>
						</td>
					</xsl:if>
				</xsl:for-each>
			</tr>
		</xsl:if>
		<xsl:if test="lsr:Number or lsr:IdByRequester or lsr:SampleCollInd or lsr:SampleCollProc">
			<tr>
				<xsl:if test="lsr:Number">
					<th>Antall</th>
					<td width="{((($col)-2)*number(not(lsr:IdByRequester | lsr:SampleCollInd | lsr:SampleCollProc))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lsr:IdByRequester | lsr:SampleCollInd | lsr:SampleCollProc))+1}">
						<xsl:value-of select="lsr:Number"/>
					</td>
				</xsl:if>
				<xsl:if test="lsr:IdByRequester">
					<th>Rekvirents&#160;id</th>
					<td width="{((($col)-2-count(lsr:Number)*2)*number(not(lsr:SampleCollInd | lsr:SampleCollProc))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:Number)*2)*number(not(lsr:SampleCollInd | lsr:SampleCollProc))+1}">
						<xsl:value-of select="lsr:IdByRequester"/>
					</td>
				</xsl:if>
				<xsl:if test="lsr:SampleCollInd">
					<th>Prøve&#160;tatt</th>
					<td width="{((($col)-2-count(lsr:Number | lsr:IdByRequester)*2)*number(not(lsr:SampleCollProc))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:Number | lsr:IdByRequester)*2)*number(not(lsr:SampleCollProc))+1}">
						<xsl:for-each select="lsr:SampleCollInd">
							<xsl:call-template name="k-1101"/>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="lsr:SampleCollProc">
					<th>Prøvetakingsprosedyre</th>
					<td colspan="{($col)-1-count(lsr:Number | lsr:IdByRequester | lsr:SampleCollInd)*2}">
						<xsl:for-each select="lsr:SampleCollProc">
							<xsl:call-template name="k-dummy"/>
						</xsl:for-each>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="lsr:AnatomicalOrigin or lsr:PreservMaterial or lsr:Pretreatment or lsr:Accredited or lsr:RelServProv">
			<tr>
				<xsl:if test="lsr:AnatomicalOrigin">
					<th>Anatomisk&#160;lokasjon</th>
					<td width="{((($col)-2)*number(not(lsr:PreservMaterial | lsr:Pretreatment | lsr:Accredited | lsr:RelServProv))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lsr:PreservMaterial | lsr:Pretreatment | lsr:Accredited | lsr:RelServProv))+1}">
						<xsl:value-of select="lsr:AnatomicalOrigin"/>
					</td>
				</xsl:if>
				<xsl:if test="lsr:PreservMaterial">
					<th>Konserveringsmiddel</th>
					<td width="{((($col)-2-count(lsr:AnatomicalOrigin)*2)*number(not(lsr:Pretreatment | lsr:Accredited | lsr:RelServProv))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:AnatomicalOrigin)*2)*number(not(lsr:Pretreatment | lsr:Accredited | lsr:RelServProv))+1}">
						<xsl:value-of select="lsr:PreservMaterial"/>
					</td>
				</xsl:if>
				<xsl:if test="lsr:Pretreatment">
					<th>Forberedende&#160;behandling</th>
					<td width="{((($col)-2-count(lsr:AnatomicalOrigin | lsr:PreservMaterial)*2)*number(not(lsr:Accredited | lsr:RelServProv))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:AnatomicalOrigin | lsr:PreservMaterial)*2)*number(not(lsr:Accredited | lsr:RelServProv))+1}">
						<xsl:for-each select="lsr:Pretreatment/lsr:Heading">
							<xsl:call-template name="k-8232"/>
						</xsl:for-each>
						<xsl:if test="lsr:Pretreatment/lsr:TextResultValue">
							<div>
								<span class="strong">Beskrivelse:&#160;</span>
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="lsr:Pretreatment/lsr:TextResultValue"/>
								</xsl:call-template>
							</div>
						</xsl:if>
					</td>
				</xsl:if>
				<xsl:if test="lsr:Accredited">
					<th>Akkreditert</th>
					<td width="{((($col)-2-count(lsr:AnatomicalOrigin | lsr:PreservMaterial | lsr:Pretreatment)*2)*number(not(lsr:RelServProv))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:AnatomicalOrigin | lsr:PreservMaterial | lsr:Pretreatment)*2)*number(not(lsr:RelServProv))+1}">
						<xsl:choose>
							<xsl:when test="lsr:Accredited/@V='true'">Prosedyren er akkreditert</xsl:when>
							<xsl:otherwise>Prosedyren er ikke akkreditert</xsl:otherwise>
						</xsl:choose>
					</td>
				</xsl:if>
				<xsl:if test="lsr:RelServProv">
					<th>
						<xsl:for-each select="lsr:RelServProv/lsr:Relation">
							<xsl:call-template name="k-8254"/>
						</xsl:for-each>
					</th>
					<td colspan="{($col)-1-count(lsr:AnatomicalOrigin | lsr:PreservMaterial | lsr:Pretreatment | lsr:Accredited)*2}">
						<xsl:value-of select="lsr:RelServProv//lsr:Name"/>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="lsr:SampleHandling">
			<tr>
				<th>Håndteringsbeskrivelse</th>
				<td colspan="{($col)-1}">
					<xsl:for-each select="lsr:SampleHandling">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="."/>
						</xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="lsr:Comment">
			<tr>
				<th>Kommentar</th>
				<td colspan="{($col)-1}">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="lsr:Comment"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
		<xsl:for-each select="lsr:AnalysedSubject">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Undersøkelsesresultat -->
	<xsl:template match="lsr:ResultItem">
		<xsl:param name="slaaSammen"/>
		<xsl:variable name="textWidth"> <!-- variabel som gjør resultat-kolonnebredden større jo mer tekst som skal vises -->
			<xsl:choose>
				<xsl:when test="lsr:TextResult/lsr:TextResultValue">
					<xsl:value-of select="ceiling(string-length(lsr:TextResult/lsr:TextResultValue) div 50)"/>
				</xsl:when>
				<xsl:when test="$slaaSammen='true' and lsr:ResultItem[1]/lsr:TextResult/lsr:TextResultValue">
					<xsl:value-of select="ceiling(string-length(lsr:ResultItem[1]/lsr:TextResult/lsr:TextResultValue) div 50)"/>
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="commentWidth"> <!-- variabel som gjør kommentar-kolonnebredden større jo mer tekst som skal vises -->
			<xsl:choose>
				<xsl:when test="lsr:Comment">
					<xsl:value-of select="ceiling(string-length(lsr:Comment) div 50)"/>
				</xsl:when>
				<xsl:when test="$slaaSammen='true' and lsr:ResultItem[1]/lsr:Comment">
					<xsl:value-of select="ceiling(string-length(lsr:ResultItem[1]/lsr:Comment) div 50)"/>
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<tr>
			<!-- Undersøkelse -->
			<xsl:if test="//lsr:Investigation or //lsr:ResultItem[lsr:TextResult/lsr:Heading/@V='GR']">
				<td width="{$investigation-col*$result-td}px" colspan="{$investigation-col}">
					<xsl:if test="lsr:TextResult/lsr:Heading/@V='GR'">
						<span class="strong">Gruppe:&#160;</span>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="lsr:Investigation">
							<div>
								<xsl:call-template name="skrivUtUndersokelse"/>
							</div>
						</xsl:when>
						<xsl:when test="$slaaSammen='true'">
							<xsl:for-each select="lsr:ResultItem[1]">
								<div>
									<xsl:call-template name="skrivUtUndersokelse"/>
								</div>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>&#160;</xsl:otherwise>
					</xsl:choose>
				</td>
			</xsl:if>
			<!-- Resultat -->
			<xsl:if test="//lsr:TextResult or //lsr:Interval or //lsr:DateResult or //lsr:NumResult">
				<td width="{($textWidth)*$result-td}px" colspan="{$res-col}">
					<xsl:choose>
						<xsl:when test="lsr:TextResult or lsr:Interval or lsr:DateResult or lsr:NumResult">
							<xsl:call-template name="skrivUtResultat"/>
						</xsl:when>
						<xsl:when test="$slaaSammen='true'">
							<xsl:for-each select="lsr:ResultItem[1]">
								<xsl:call-template name="skrivUtResultat"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>&#160;</xsl:otherwise>
					</xsl:choose>
				</td>
			</xsl:if>
			<!-- Id -->
			<xsl:if test="//lsr:IdResultItem">
				<td width="{$id-col*$id-td}px" colspan="{$id-col}">
					<xsl:choose>
						<xsl:when test="lsr:IdResultItem">
							<xsl:value-of select="lsr:IdResultItem"/>
						</xsl:when>
						<xsl:when test="$slaaSammen='true'">
							<xsl:for-each select="lsr:ResultItem[1]">
								<xsl:value-of select="lsr:IdResultItem"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>&#160;</xsl:otherwise>
					</xsl:choose>
				</td>
			</xsl:if>
			<!-- Ref.id -->
			<xsl:if test="//lsr:RefIdResultItem">
				<td width="{$refid-col*$id-td}px" colspan="{$refid-col}">
					<xsl:choose>
						<xsl:when test="lsr:RefIdResultItem">
							<xsl:value-of select="lsr:RefIdResultItem"/>
						</xsl:when>
						<xsl:when test="$slaaSammen='true'">
							<xsl:for-each select="lsr:ResultItem[1]">
								<xsl:value-of select="lsr:RefIdResultItem"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>&#160;</xsl:otherwise>
					</xsl:choose>
				</td>
			</xsl:if>
			<!-- Ref.interval -->
			<xsl:if test="//lsr:RefInterval">
				<td width="{$refinterval-col*$result-td}px" colspan="{$refinterval-col}">
					<xsl:choose>
						<xsl:when test="lsr:RefInterval">
							<xsl:call-template name="skrivUtRefInterval"/>
						</xsl:when>
						<xsl:when test="$slaaSammen='true'">
							<xsl:for-each select="lsr:ResultItem[1]">
								<xsl:call-template name="skrivUtRefInterval"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>&#160;</xsl:otherwise>
					</xsl:choose>
				</td>
			</xsl:if>
			<!-- Tidspunkt for -->
			<xsl:if test="//lsr:InvDate or //lsr:StatusChangeDate or //lsr:DescrDate or //lsr:CounterSignDate or //lsr:MedicalValidationDate">
				<td width="{$date-col*$result-td}px" colspan="{$date-col}">
					<xsl:choose>
						<xsl:when test="lsr:InvDate or lsr:StatusChangeDate or lsr:DescrDate or lsr:CounterSignDate or lsr:MedicalValidationDate">
							<xsl:call-template name="skrivUtTidspunktFor"/>
						</xsl:when>
						<xsl:when test="$slaaSammen='true'">
							<xsl:for-each select="lsr:ResultItem[1]">
								<xsl:call-template name="skrivUtTidspunktFor"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>&#160;</xsl:otherwise>
					</xsl:choose>
				</td>
			</xsl:if>
			<!-- Tilknyttet tjenesteyter -->
			<xsl:if test="//lsr:RelServProv">
				<td width="{$relserv-col*$result-td}px" colspan="{$relserv-col}">
					<xsl:choose>
						<xsl:when test="lsr:RelServProv">
							<xsl:call-template name="skrivUtTjenesteyter"/>
						</xsl:when>
						<xsl:when test="$slaaSammen='true'">
							<xsl:for-each select="lsr:ResultItem[1]">
								<xsl:call-template name="skrivUtTjenesteyter"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>&#160;</xsl:otherwise>
					</xsl:choose>
				</td>
			</xsl:if>
			<!-- Tilleggsopplysninger -->
			<xsl:if test="//lsr:Accredited or //lsr:StructuredInfo or //lsr:Investigation/lsr:Comment or //lsr:Investigation/lsr:Spec or //lsr:Comment or //lsr:DiagComment or //lsr:RefAnalysedSubject or //lsr:StatusInvestigation">
				<td width="{$commentWidth*$std-td}px" colspan="{$tillegg-col}">
					<xsl:choose>
						<xsl:when test="lsr:Accredited or lsr:StructuredInfo or lsr:Investigation/lsr:Comment or lsr:Investigation/lsr:Spec or lsr:Comment or lsr:DiagComment or lsr:RefAnalysedSubject or lsr:StatusInvestigation">
							<xsl:call-template name="skrivUtTillegg"/>
						</xsl:when>
						<xsl:when test="$slaaSammen='true'">
							<xsl:for-each select="lsr:ResultItem[1]">
								<xsl:call-template name="skrivUtTillegg"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>&#160;</xsl:otherwise>
					</xsl:choose>
				</td>
			</xsl:if>
		</tr>
	</xsl:template>
	<xsl:template match="lsr:ResultItem" mode="StructuredInfo">
		<table>
			<tbody>
				<tr>
					<th>Type</th>
					<td><b>Resultat</b></td>
				</tr>
				<xsl:for-each select="lsr:StructuredInfo">
					<tr>
						<td>
							<xsl:for-each select="lsr:Type">
								<xsl:call-template name="k-dummy"/>
							</xsl:for-each>
						</td>
						<td>
							<xsl:for-each select="lsr:TextInfo">
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="lsr:Text"/>
								</xsl:call-template>&#160;
							</xsl:for-each>
							<xsl:for-each select="lsr:IntegerInfo">
								<xsl:value-of select="lsr:Integer"/>&#160;
							</xsl:for-each>
							<xsl:for-each select="lsr:PhysicalInfo">
								<xsl:value-of select="lsr:Quantity/@V"/>&#160;<xsl:value-of select="lsr:Quantity/@U"/>&#160;
							</xsl:for-each>
							<xsl:for-each select="lsr:CodedInfo/lsr:Code">
								<xsl:call-template name="k-dummy"/>&#160;
							</xsl:for-each>
							<xsl:for-each select="lsr:BooleanInfo">
								<xsl:value-of select="lsr:Flag/@V"/>&#160;
							</xsl:for-each>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
	<!-- Visning av Klinisk opplysning -->
	<xsl:template match="lsr:InfItem">
		<xsl:param name="col"/>
		<xsl:variable name="type" select="lsr:Type/@V"/>
		<xsl:if test="not(preceding-sibling::lsr:InfItem[lsr:Type/@V=$type])">
			<tr>
				<th colspan="{$col}" class="h3">
					<xsl:for-each select="lsr:Type">
						<xsl:call-template name="k-8233"/>
					</xsl:for-each>
				</th>
			</tr>
		</xsl:if>
		<xsl:if test="lsr:Observation/lsr:Description or lsr:Observation/lsr:CodedDescr or lsr:StartDateTime or lsr:EndDateTime or lsr:OrgDate">
			<tr>
				<xsl:if test="lsr:Observation/lsr:Description or lsr:Observation/lsr:CodedDescr">
					<th>Beskrivelse</th>
					<td width="{((($col)-2)*number(not(lsr:StartDateTime | lsr:EndDateTime | lsr:OrgDate))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lsr:StartDateTime | lsr:EndDateTime | lsr:OrgDate))+1}">
						<xsl:for-each select="lsr:Observation/lsr:Description">
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
						<xsl:if test="lsr:Observation/lsr:CodedDescr">
							<div>
								<xsl:for-each select="lsr:Observation/lsr:CodedDescr">
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
				<xsl:if test="lsr:StartDateTime">
					<th>Start-dato</th>
					<td width="{((($col)-2-count(lsr:Observation/lsr:Description)*2)*number(not(lsr:EndDateTime | lsr:OrgDate))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:Observation/lsr:Description)*2)*number(not(lsr:EndDateTime | lsr:OrgDate))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="lsr:StartDateTime/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="lsr:EndDateTime">
					<th>Slutt-dato</th>
					<td width="{((($col)-2-count(lsr:Observation/lsr:Description | lsr:StartDateTime)*2)*number(not(lsr:OrgDate))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:Observation/lsr:Description | lsr:StartDateTime)*2)*number(not(lsr:OrgDate))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="lsr:EndDateTime/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="lsr:OrgDate">
					<th>Opprinnelses-dato</th>
					<td colspan="{($col)-1-count(lsr:Observation/lsr:Description | lsr:StartDateTime | lsr:EndDateTime)*2}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="lsr:OrgDate/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="lsr:Observation/lsr:Comment">
			<tr>
				<th>Kommentar</th>
				<td colspan="{($col)-1}">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="lsr:Observation/lsr:Comment"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
	<!-- Visning av Tjenesteyter -->
	<xsl:template match="lsr:ServProvider">
		<xsl:param name="col"/>
		<xsl:param name="historikk"/>
		<tr>
			<th colspan="{$col}" class="h3">Avsender<xsl:if test="lsr:HCP/lsr:MedSpeciality"> - Spesialitet:&#160;<xsl:for-each select="lsr:HCP/lsr:MedSpeciality">
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
				<xsl:if test="$historikk='true'">&#160;(<font color="red">fra historikk</font>)</xsl:if>
			</th>
		</tr>
		<xsl:for-each select="lsr:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Henvisende instans -->
	<xsl:template match="lsr:Requester">
		<xsl:param name="col"/>
		<xsl:param name="historikk"/>
		<tr>
			<th colspan="{$col}" class="h3">Mottaker<xsl:if test="lsr:HCP/lsr:MedSpeciality"> - Spesialitet:&#160;<xsl:for-each select="lsr:HCP/lsr:MedSpeciality">
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
				<xsl:if test="$historikk='true'">&#160;(<font color="red">fra historikk</font>)</xsl:if>
			</th>
		</tr>
		<xsl:for-each select="lsr:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Betalingsansvarlig -->
	<xsl:template match="lsr:PaymentResponsible">
		<xsl:param name="col"/>
		<xsl:param name="historikk"/>
		<tr>
			<th colspan="{$col}" class="h3">Betalingsansvarlig<xsl:if test="lsr:TypeGuarantor"> - <xsl:value-of select="lsr:TypeGuarantor"/></xsl:if>
				<xsl:if test="$historikk='true'">&#160;(<font color="red">fra historikk</font>)</xsl:if>
			</th>
		</tr>
		<xsl:for-each select="lsr:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Kopimottaker -->
	<xsl:template match="lsr:CopyDest">
		<xsl:param name="col"/>
		<xsl:param name="historikk"/>
		<tr>
			<th colspan="{$col}" class="h3">Kopimottaker<xsl:if test="lsr:CopyDestRole/lsr:MsgType"> - kopi&#160;av:&#160;<xsl:for-each select="lsr:CopyDestRole/lsr:MsgType">
						<xsl:call-template name="k-8236"/>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="$historikk='true'">&#160;(<font color="red">fra historikk</font>)</xsl:if>
			</th>
		</tr>
		<xsl:for-each select="lsr:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Tilknyttet tjeneteyter -->
	<xsl:template match="lsr:RelServProv">
		<xsl:param name="col"/>
		<xsl:param name="historikk"/>
		<tr>
			<th colspan="{$col}" class="h3">
				<xsl:for-each select="lsr:Relation">
					<xsl:call-template name="k-8254"/>
				</xsl:for-each>
				<xsl:if test="$historikk='true'">&#160;(<font color="red">fra historikk</font>)</xsl:if>
			</th>
		</tr>
		<xsl:for-each select="lsr:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Ansvarlig Helsetjenesteenhet -->
	<xsl:template match="lsr:ResponsibleHcp">
		<xsl:param name="col"/>
		<xsl:param name="historikk"/>
		<tr>
			<th colspan="{$col}" class="h3">
				<xsl:choose>
					<xsl:when test="lsr:Relation/@DN">
						<xsl:for-each select="lsr:Relation">
							<xsl:call-template name="k-8254"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Ansvarlig&#160;helsetjenesteenhet</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$historikk='true'">&#160;(<font color="red">fra historikk</font>)</xsl:if>
			</th>
		</tr>
		<xsl:for-each select="lsr:HCP">
			<xsl:apply-templates select=".">
				<xsl:with-param name="col" select="$col"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Oppholdsted -->
	<xsl:template match="lsr:AdmLocation">
		<xsl:param name="col"/>
		<xsl:param name="historikk"/>
		<tr>
			<th colspan="{$col}" class="h3">Oppholdssted for pasient<xsl:if test="lsr:AdmCat"> - Type&#160;tjeneste:&#160;<xsl:for-each select="lsr:AdmCat">
						<xsl:call-template name="k-8240"/>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="$historikk='true'">&#160;(<font color="red">fra historikk</font>)</xsl:if>
			</th>
		</tr>
		<xsl:for-each select="lsr:Location/lsr:Inst">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="lsr:Location/lsr:Inst/lsr:Dept">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="lsr:Location/lsr:Inst/lsr:HCPerson">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="lsr:Location/lsr:Address">
			<xsl:variable name="antall-tel" select="count(lsr:TeleAddress)"/>
			<tr>
				<xsl:apply-templates select="lsr:TeleAddress">
					<xsl:with-param name="col" select="(($col)-1)*number(not(lsr:Type and (lsr:PostalCode or lsr:City)))+1"/>
				</xsl:apply-templates>
				<xsl:if test="lsr:Type and (lsr:PostalCode or lsr:City)">
					<xsl:apply-templates select=".">
						<xsl:with-param name="col" select="($col)-1-($antall-tel)*2"/>
					</xsl:apply-templates>
				</xsl:if>
			</tr>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Helsetjenesteenhet -->
	<xsl:template match="lsr:HCP">
		<xsl:param name="col"/>
		<xsl:for-each select="lsr:Inst">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="lsr:Inst/lsr:Dept">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="lsr:Inst/lsr:HCPerson">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="lsr:HCProf">
			<tr>
				<xsl:apply-templates select=".">
					<xsl:with-param name="col" select="$col"/>
				</xsl:apply-templates>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="lsr:Address">
			<xsl:variable name="antall-tel" select="count(lsr:TeleAddress)"/>
			<tr>
				<xsl:apply-templates select="lsr:TeleAddress">
					<xsl:with-param name="col" select="(($col)-1)*number(not(lsr:Type and (lsr:PostalCode or lsr:City)))+1"/>
				</xsl:apply-templates>
				<xsl:if test="lsr:Type and (lsr:PostalCode or lsr:City)">
					<xsl:apply-templates select=".">
						<xsl:with-param name="col" select="($col)-1-($antall-tel)*2"/>
					</xsl:apply-templates>
				</xsl:if>
			</tr>
		</xsl:for-each>
	</xsl:template>
	<!-- Visning av Person i helsevesenet -->
	<xsl:template match="lsr:HCProf">
		<xsl:param name="col"/>
		<xsl:if test="lsr:Type or lsr:Name">
			<th>
				<xsl:choose>
					<xsl:when test="lsr:Type">
						<xsl:for-each select="lsr:Type">
							<xsl:call-template name="k-9060"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Helsepersonell</xsl:otherwise>
				</xsl:choose>
			</th>
			<td width="{$std-td}px">
				<xsl:value-of select="lsr:Name"/>
			</td>
		</xsl:if>
		<xsl:if test="lsr:Id or lsr:AdditionalId">
			<th>
				<xsl:choose>
					<xsl:when test="lsr:TypeId">
						<xsl:for-each select="lsr:TypeId">
							<xsl:call-template name="k-8116"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Id</xsl:otherwise>
				</xsl:choose>
			</th>
			<xsl:choose>
				<xsl:when test="lsr:AdditionalId">
					<td width="{$std-td}px">
						<xsl:value-of select="lsr:Id"/>
					</td>
				</xsl:when>
				<xsl:otherwise>
					<td colspan="{($col)-3}">
						<xsl:value-of select="lsr:Id"/>
					</td>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="lsr:AdditionalId">
				<xsl:variable name="antall-id" select="count(lsr:AdditionalId)"/>
				<xsl:for-each select="lsr:AdditionalId">
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
	<xsl:template match="lsr:Inst">
		<xsl:param name="col"/>
		<xsl:if test="lsr:Name">
			<th>Navn</th>
			<td width="{$std-td}px">
				<xsl:value-of select="lsr:Name"/>
			</td>
		</xsl:if>
		<xsl:if test="lsr:Id or lsr:AdditionalId">
			<th>
				<xsl:choose>
					<xsl:when test="lsr:TypeId">
						<xsl:for-each select="lsr:TypeId">
							<xsl:call-template name="k-9051"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Id</xsl:otherwise>
				</xsl:choose>
			</th>
			<xsl:choose>
				<xsl:when test="lsr:AdditionalId">
					<td width="{$std-td}px">
						<xsl:value-of select="lsr:Id"/>
					</td>
				</xsl:when>
				<xsl:otherwise>
					<td colspan="{($col)-3}">
						<xsl:value-of select="lsr:Id"/>
					</td>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="lsr:AdditionalId">
				<xsl:variable name="antall-id" select="count(lsr:AdditionalId)"/>
				<xsl:for-each select="lsr:AdditionalId">
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
	<xsl:template match="lsr:Dept">
		<xsl:param name="col"/>
		<xsl:if test="lsr:Type or lsr:Name">
			<th>
				<xsl:choose>
					<xsl:when test="lsr:Type">
						<xsl:for-each select="lsr:Type">
							<xsl:call-template name="k-8624"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Avdeling</xsl:otherwise>
				</xsl:choose>
			</th>
			<td width="{$std-td}px">
				<xsl:value-of select="lsr:Name"/>
			</td>
		</xsl:if>
		<xsl:if test="lsr:Id or lsr:AdditionalId">
			<th>
				<xsl:choose>
					<xsl:when test="lsr:TypeId">
						<xsl:for-each select="lsr:TypeId">
							<xsl:call-template name="k-9051"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Id</xsl:otherwise>
				</xsl:choose>
			</th>
			<xsl:choose>
				<xsl:when test="lsr:AdditionalId">
					<td width="{$std-td}px">
						<xsl:value-of select="lsr:Id"/>
					</td>
				</xsl:when>
				<xsl:otherwise>
					<td colspan="{($col)-3}">
						<xsl:value-of select="lsr:Id"/>
					</td>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="lsr:AdditionalId">
				<xsl:variable name="antall-id" select="count(lsr:AdditionalId)"/>
				<xsl:for-each select="lsr:AdditionalId">
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
	<xsl:template match="lsr:HCPerson">
		<xsl:param name="col"/>
		<xsl:if test="lsr:Name">
			<th>Helsepersonell</th>
			<td width="{$std-td}px">
				<xsl:value-of select="lsr:Name"/>
			</td>
		</xsl:if>
		<xsl:if test="lsr:Id or lsr:AdditionalId">
			<th>
				<xsl:choose>
					<xsl:when test="lsr:TypeId">
						<xsl:for-each select="lsr:TypeId">
							<xsl:call-template name="k-8116"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Id</xsl:otherwise>
				</xsl:choose>
			</th>
			<xsl:choose>
				<xsl:when test="lsr:AdditionalId">
					<td width="{$std-td}px">
						<xsl:value-of select="lsr:Id"/>
					</td>
				</xsl:when>
				<xsl:otherwise>
					<td colspan="{($col)-3}">
						<xsl:value-of select="lsr:Id"/>
					</td>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="lsr:AdditionalId">
				<xsl:variable name="antall-id" select="count(lsr:AdditionalId)"/>
				<xsl:for-each select="lsr:AdditionalId">
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
	<xsl:template match="lsr:AdditionalId">
		<xsl:param name="col"/>
		<th>
			<xsl:for-each select="lsr:Type">
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
			<xsl:value-of select="lsr:Id"/>
		</td>
	</xsl:template>
	<!-- Visning av Adresse -->
	<xsl:template match="lsr:Address">
		<xsl:param name="col"/>
		<th>
			<xsl:choose>
				<xsl:when test="lsr:Type">
					<xsl:for-each select="lsr:Type">
						<xsl:call-template name="k-3401"/>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>Adresse</xsl:otherwise>
			</xsl:choose>
		</th>
		<td colspan="{$col}">
			<xsl:if test="lsr:StreetAdr">
				<xsl:value-of select="lsr:StreetAdr"/>,&#160;</xsl:if>
			<xsl:if test="lsr:PostalCode">
				<xsl:value-of select="lsr:PostalCode"/>
			</xsl:if>
			<xsl:if test="lsr:City">&#160;<xsl:value-of select="lsr:City"/>
			</xsl:if>
			<xsl:if test="lsr:CityDistr">,&#160;<xsl:for-each select="lsr:CityDistr"><xsl:call-template name="k-3403"/></xsl:for-each>
			</xsl:if>
			<xsl:if test="lsr:County">,&#160;<xsl:for-each select="lsr:County"><xsl:call-template name="k-3402"/></xsl:for-each>
			</xsl:if>
			<xsl:if test="lsr:Country">,&#160;<xsl:for-each select="lsr:Country"><xsl:call-template name="k-9043"/></xsl:for-each>
			</xsl:if>
		</td>
	</xsl:template>
	<!-- Visning av Telekommunikasjon -->
	<xsl:template match="lsr:TeleAddress">
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
	<xsl:template match="lsr:RefDoc">
		<xsl:param name="col"/>
		<xsl:if test="lsr:MsgType or lsr:Id or lsr:IssueDate or lsr:MimeType or lsr:Compression">
			<tr>
				<xsl:if test="lsr:MsgType">
					<th>Type</th>
					<td width="{((($col)-2)*number(not(lsr:Id | lsr:IssueDate | lsr:MimeType | lsr:Compression))+1)*$std-td}px" colspan="{(($col)-2)*number(not(lsr:Id | lsr:IssueDate | lsr:MimeType | lsr:Compression))+1}">
						<xsl:for-each select="lsr:MsgType">
							<xsl:call-template name="k-8114"/>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="lsr:Id">
					<th>Id</th>
					<td width="{((($col)-2-count(lsr:MsgType)*2)*number(not(lsr:IssueDate | lsr:MimeType | lsr:Compression))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:MsgType)*2)*number(not(lsr:IssueDate | lsr:MimeType | lsr:Compression))+1}">
						<xsl:value-of select="lsr:Id"/>
					</td>
				</xsl:if>
				<xsl:if test="lsr:IssueDate">
					<th>Utstedt-dato</th>
					<td width="{((($col)-2-count(lsr:MsgType | lsr:Id)*2)*number(not(lsr:MimeType | lsr:Compression))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:MsgType | lsr:Id)*2)*number(not(lsr:MimeType | lsr:Compression))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="lsr:IssueDate/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="lsr:MimeType">
					<th>Mimetype</th>
					<td width="{((($col)-2-count(lsr:MsgType | lsr:Id | lsr:IssueDate)*2)*number(not(lsr:Compression))+1)*$std-td}px" colspan="{(($col)-2-count(lsr:MsgType | lsr:Id | lsr:IssueDate)*2)*number(not(lsr:Compression))+1}">
						<xsl:value-of select="lsr:MimeType"/>
					</td>
				</xsl:if>
				<xsl:if test="lsr:Compression">
					<th>Komprimering</th>
					<td colspan="{($col)-1-count(lsr:MsgType | lsr:Id | lsr:IssueDate | lsr:MimeType)*2}">
						<xsl:for-each select="lsr:Compression">
							<xsl:call-template name="k-1204"/>
						</xsl:for-each>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="lsr:Description">
			<tr>
				<th>Beskrivelse</th>
				<td colspan="{($col)-1}">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="lsr:Description"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="lsr:Content or lsr:FileReference">
			<xsl:choose>
				<xsl:when test="contains(lsr:MimeType,'image')">
					<tr>
						<th>Bilde</th>
						<xsl:choose>
							<xsl:when test="lsr:FileReference">
								<td colspan="{($col)-1}">
									<img>
										<xsl:attribute name="src"><xsl:value-of select="lsr:FileReference"/></xsl:attribute>
										<xsl:attribute name="alt">Bilde fra ekstern URL</xsl:attribute>
									</img>
								</td>
							</xsl:when>
							<xsl:when test="lsr:Content">
								<td colspan="{($col)-1}">
									<xsl:choose>
										<xsl:when test="lsr:Content/base:Base64Container">
											<img>
												<xsl:attribute name="src"><xsl:value-of select="concat('data:',lsr:MimeType,';base64,',lsr:Content/base:Base64Container)"/></xsl:attribute>
												<xsl:attribute name="alt">Bilde vedlagt som base64-kode</xsl:attribute>
											</img>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="lsr:Content"/>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:when>
						</xsl:choose>
					</tr>
				</xsl:when>
				<xsl:when test="contains(lsr:MimeType,'pdf')">
					<tr>
						<th>pdf</th>
						<xsl:choose>
							<xsl:when test="lsr:FileReference">
								<td colspan="{($col)-1}">
									<object>
										<xsl:attribute name="data"><xsl:value-of select="concat(lsr:FileReference,'&#35;view&#61;FitH&#38;toolbar&#61;1')"/></xsl:attribute>
										<xsl:attribute name="type">application/pdf</xsl:attribute>
										<xsl:attribute name="width">100%</xsl:attribute>
										<xsl:attribute name="height">500px</xsl:attribute>
									</object>
								</td>
							</xsl:when>
							<xsl:when test="lsr:Content">
								<td colspan="{($col)-1}">
									<xsl:choose>
										<xsl:when test="lsr:Content/base:Base64Container">
											<object>
												<xsl:attribute name="data"><xsl:value-of select="concat('data:application/pdf;base64,',lsr:Content/base:Base64Container)"/></xsl:attribute>
												<xsl:attribute name="type">application/pdf</xsl:attribute>
												<xsl:attribute name="width">100%</xsl:attribute>
												<xsl:attribute name="height">500px</xsl:attribute>
											</object>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="lsr:Content"/>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:when>
						</xsl:choose>
					</tr>
				</xsl:when>
				<xsl:otherwise>
					<tr>
						<th>Fil</th>
						<td colspan="{($col)-1}">
							<xsl:choose>
								<xsl:when test="lsr:Content">
									<xsl:value-of select="lsr:Content"/>
								</xsl:when>
								<xsl:when test="lsr:FileReference">
									<xsl:value-of select="lsr:FileReference"/>
								</xsl:when>
							</xsl:choose>
						</td>
					</tr>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<!-- funksjoner som kalles ved visning av resultattabellen-->
	<xsl:template name="skrivUtUndersokelseOverskrift">
		<tr>
			<!-- Overskrift for Undersøkelse -->
			<xsl:if test="//lsr:Investigation or //lsr:ResultItem[lsr:TextResult/lsr:Heading/@V='GR']">
				<th colspan="{$investigation-col}">Undersøkelse</th>
			</xsl:if>
			<!-- Overskrift for Resultat -->
			<xsl:if test="//lsr:TextResult or //lsr:Interval or //lsr:DateResult or //lsr:NumResult">
				<td colspan="{$res-col}">
					<span class="strong">
						<xsl:choose>
							<xsl:when test="lsr:TextResult/lsr:Heading and lsr:TextResult/lsr:Heading/@V!='GR'">
								<xsl:for-each select="lsr:TextResult/lsr:Heading">
									<xsl:call-template name="k-8243"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>Resultat</xsl:otherwise>
						</xsl:choose>
					</span>
				</td>
			</xsl:if>
			<!-- Overskrift for Id -->
			<xsl:if test="//lsr:IdResultItem">
				<th colspan="{$id-col}">Id</th>
			</xsl:if>
			<!-- Overskrift for Ref.id -->
			<xsl:if test="//lsr:RefIdResultItem">
				<th colspan="{$refid-col}">Ref.id</th>
			</xsl:if>
			<!-- Overskrift for Ref.interval -->
			<xsl:if test="//lsr:RefInterval">
				<th colspan="{$refinterval-col}">Ref.interval</th>
			</xsl:if>
			<!-- Overskrift for Tidspunkt -->
			<xsl:if test="//lsr:InvDate or //lsr:StatusChangeDate or //lsr:DescrDate or //lsr:CounterSignDate or //lsr:MedicalValidationDate">
				<th colspan="{$date-col}">
					<xsl:choose>
						<xsl:when test="//lsr:InvDate and not(//lsr:StatusChangeDate) and not(//lsr:DescrDate) and not(//lsr:CounterSignDate) and not(//lsr:MedicalValidationDate)">Tidspunkt for undersøkelsen</xsl:when>
						<xsl:when test="not(//lsr:InvDate) and //lsr:StatusChangeDate and not(//lsr:DescrDate) and not(//lsr:CounterSignDate) and not(//lsr:MedicalValidationDate)">Tidspunkt for beskrivelse</xsl:when>
						<xsl:when test="not(//lsr:InvDate) and not(//lsr:StatusChangeDate) and //lsr:DescrDate and not(//lsr:CounterSignDate) and not(//lsr:MedicalValidationDate)">Tidspunkt for beskrivelse</xsl:when>
						<xsl:when test="not(//lsr:InvDate) and not(//lsr:StatusChangeDate) and not(//lsr:DescrDate) and //lsr:CounterSignDate and not(//lsr:MedicalValidationDate)">Tidspunkt for kontrasignering</xsl:when>
						<xsl:when test="not(//lsr:InvDate) and not(//lsr:StatusChangeDate) and not(//lsr:DescrDate) and not(//lsr:CounterSignDate) and //lsr:MedicalValidationDate">Tidspunkt for medisinsk validering</xsl:when>
						<xsl:otherwise>Tidspunkt for</xsl:otherwise>
					</xsl:choose>
				</th>
			</xsl:if>
			<!-- Overskrift for Tilknyttet tjenesteyter -->
			<xsl:if test="//lsr:ResultItem/lsr:RelServProv">
				<th colspan="{$relserv-col}">
					<xsl:choose>
						<xsl:when test="//lsr:RelServProv/lsr:Relation">
							<xsl:for-each select="//lsr:RelServProv/lsr:Relation">
								<xsl:if test="position()=1">
									<xsl:variable name="relationOne">
										<xsl:value-of select="@V"/>
									</xsl:variable>
									<xsl:choose>
										<xsl:when test="count(//lsr:RelServProv/lsr:Relation)=count(//lsr:RelServProv/lsr:Relation[@V=$relationOne])"><!-- Samme kode i alle relation-elementene -->
											<xsl:call-template name="k-8254"/>
										</xsl:when>
										<xsl:otherwise>Tilknyttet avsender</xsl:otherwise>
									</xsl:choose>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Tilknyttet avsender</xsl:otherwise>
					</xsl:choose>
				</th>
			</xsl:if>
			<!-- Overskrift for Tilleggsopplysninger -->
			<xsl:if test="//lsr:Accredited or //lsr:StructuredInfo or //lsr:Investigation/lsr:Comment or //lsr:Investigation/lsr:Spec or //lsr:ResultItem/lsr:Comment or //lsr:DiagComment or //lsr:RefAnalysedSubject or //lsr:StatusInvestigation">
				<td colspan="{$tillegg-col}">
					<xsl:choose>
						<xsl:when test="//lsr:Accredited and not(//lsr:StructuredInfo) and not(//lsr:Investigation/lsr:Comment) and not(//lsr:Investigation/lsr:Spec) and not(//lsr:ResultItem/lsr:Comment) and not(//lsr:DiagComment) and not(//lsr:RefAnalysedSubject) and not(//lsr:StatusInvestigation)"><b>Akkreditert</b></xsl:when>
						<xsl:when test="not(//lsr:Accredited) and //lsr:StructuredInfo and not(//lsr:Investigation/lsr:Comment) and not(//lsr:Investigation/lsr:Spec) and not(//lsr:ResultItem/lsr:Comment) and not(//lsr:DiagComment) and not(//lsr:RefAnalysedSubject) and not(//lsr:StatusInvestigation)"><b>Strukturert info</b></xsl:when>
						<xsl:when test="not(//lsr:Accredited) and not(//lsr:StructuredInfo) and //lsr:Investigation/lsr:Comment and not(//lsr:Investigation/lsr:Spec) and not(//lsr:ResultItem/lsr:Comment) and not(//lsr:DiagComment) and not(//lsr:RefAnalysedSubject) and not(//lsr:StatusInvestigation)"><b>Kommentar</b></xsl:when>
						<xsl:when test="not(//lsr:Accredited) and not(//lsr:StructuredInfo) and not(//lsr:Investigation/lsr:Comment) and //lsr:Investigation/lsr:Spec and not(//lsr:ResultItem/lsr:Comment) and not(//lsr:DiagComment) and not(//lsr:RefAnalysedSubject) and not(//lsr:StatusInvestigation)"><b>Spesifisering</b></xsl:when>
						<xsl:when test="not(//lsr:Accredited) and not(//lsr:StructuredInfo) and not(//lsr:Investigation/lsr:Comment) and not(//lsr:Investigation/lsr:Spec) and //lsr:ResultItem/lsr:Comment and not(//lsr:DiagComment) and not(//lsr:RefAnalysedSubject) and not(//lsr:StatusInvestigation)"><b>Kommentar til undersøkelsen</b></xsl:when>
						<xsl:when test="not(//lsr:Accredited) and not(//lsr:StructuredInfo) and not(//lsr:Investigation/lsr:Comment) and not(//lsr:Investigation/lsr:Spec) and not(//lsr:ResultItem/lsr:Comment) and //lsr:DiagComment and not(//lsr:RefAnalysedSubject) and not(//lsr:StatusInvestigation)"><b>Kommentar som diagnose</b></xsl:when>
						<xsl:when test="not(//lsr:Accredited) and not(//lsr:StructuredInfo) and not(//lsr:Investigation/lsr:Comment) and not(//lsr:Investigation/lsr:Spec) and not(//lsr:ResultItem/lsr:Comment) and not(//lsr:DiagComment) and //lsr:RefAnalysedSubject and not(//lsr:StatusInvestigation)"><b>Referanse til prøve</b></xsl:when>
						<xsl:when test="not(//lsr:Accredited) and not(//lsr:StructuredInfo) and not(//lsr:Investigation/lsr:Comment) and not(//lsr:Investigation/lsr:Spec) and not(//lsr:ResultItem/lsr:Comment) and not(//lsr:DiagComment) and not(//lsr:RefAnalysedSubject) and //lsr:StatusInvestigation"><b>Undersøkelsesstatus</b></xsl:when>
						<xsl:otherwise><b>Tilleggsopplysninger</b></xsl:otherwise>
					</xsl:choose>
				</td>
			</xsl:if>
		</tr>
	</xsl:template>
	<xsl:template name="skrivUtUndersokelse">
		<xsl:for-each select="lsr:ServType">
			<xsl:if test="@V!='N' and @V!='H'"><b><font color="red"><xsl:call-template name="k-7309"/></font></b>&#160;-&#160;</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="lsr:Investigation/lsr:Id">
			<xsl:choose>
				<xsl:when test="contains(@S, '8212')">
					<xsl:call-template name="k-dummy-OT"/>
				</xsl:when>
				<xsl:when test="contains(@S, '8219')">
					<xsl:call-template name="k-8219"/>
				</xsl:when>
				<xsl:when test="contains(@S, '8220')">
					<xsl:call-template name="k-8220"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="k-dummy-V"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="position()!=last()">,&#160;</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="skrivUtResultat">
		<xsl:choose>
			<xsl:when test="lsr:TextResult">
				<xsl:for-each select="lsr:TextResult/lsr:Heading[@V='AN' or @V='VU' or @V='UP' or @V='SY']">
					<b><xsl:call-template name="k-8243"/></b>:&#160;
				</xsl:for-each>
				<xsl:for-each select="lsr:TextResult/lsr:TextResultValue">
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
				<xsl:for-each select="lsr:TextResult/lsr:TextCode">
					<xsl:choose>
						<xsl:when test="contains(@S, '7010')">
							<div><b>NORPAT:</b>&#160;<xsl:call-template name="k-dummy-V"/></div>
						</xsl:when>
						<xsl:when test="contains(@S, '8212')">
							<div><xsl:call-template name="k-dummy-OT"/></div>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="k-dummy"/>
							<xsl:if test="position()!=last()"><br/></xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				<xsl:if test="lsr:TextResult/lsr:Unit">
					<span class="strong">Benevning:</span>&#160;<xsl:value-of select="lsr:TextResult/lsr:Unit"/>&#160;
				</xsl:if>
			</xsl:when>
			<xsl:when test="lsr:Interval">
				<xsl:value-of select="lsr:Interval/lsr:Low/@V"/>&#160;<xsl:value-of select="lsr:Interval/lsr:Low/@U"/>&#160;-&#160;<xsl:value-of select="lsr:Interval/lsr:High/@V"/>&#160;<xsl:value-of select="lsr:Interval/lsr:High/@U"/>
			</xsl:when>
			<xsl:when test="DateResult">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="lsr:DateResult/@V"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="lsr:NumResult">
				<xsl:for-each select="lsr:NumResult/lsr:ArithmeticComp">
					<xsl:call-template name="k-8239"/>&#160;
				</xsl:for-each>
				<xsl:value-of select="lsr:NumResult/lsr:NumResultValue/@V"/>&#160;<xsl:value-of select="lsr:NumResult/lsr:NumResultValue/@U"/>&#160;
				<xsl:for-each select="lsr:DevResultInd">
					<b><xsl:call-template name="k-8244"/></b>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="skrivUtRefInterval">
		<xsl:for-each select="lsr:RefInterval">
			<xsl:value-of select="lsr:Descr"/>&#160;
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="skrivUtTidspunktFor">
		<xsl:if test="lsr:InvDate">
			<xsl:if test="//lsr:DescrDate or //lsr:StatusChangeDate or //lsr:CounterSignDate or //lsr:MedicalValidationDate"><b>Undersøkelse</b>:&#160;</xsl:if>
			<div>
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="lsr:InvDate/@V"/>
				</xsl:call-template>
			</div>
		</xsl:if>
		<xsl:if test="lsr:DescrDate">
			<xsl:if test="//lsr:InvDate or //lsr:StatusChangeDate or //lsr:CounterSignDate or //lsr:MedicalValidationDate"><b>Beskrivelse</b>:&#160;</xsl:if>
			<div>
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="lsr:DescrDate/@V"/>
				</xsl:call-template>
			</div>
		</xsl:if>
		<xsl:if test="lsr:StatusChangeDate">
			<xsl:if test="//lsr:InvDate or //lsr:DescrDate or //lsr:CounterSignDate or //lsr:MedicalValidationDate"><b>Statusendring</b>:&#160;</xsl:if>
			<div>
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="lsr:StatusChangeDate/@V"/>
				</xsl:call-template>
			</div>
		</xsl:if>
		<xsl:if test="lsr:CounterSignDate">
			<xsl:if test="//lsr:InvDate or //lsr:DescrDate or //lsr:StatusChangeDate or //lsr:MedicalValidationDate"><b>Kontrasignering</b>:&#160;</xsl:if>
			<div>
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="lsr:CounterSignDate/@V"/>
				</xsl:call-template>
			</div>
		</xsl:if>
		<xsl:if test="lsr:MedicalValidationDate">
			<xsl:if test="//lsr:InvDate or //lsr:DescrDate or //lsr:StatusChangeDate or //lsr:CounterSignDate"><b>Medisinsk&#160;validering</b>:&#160;</xsl:if>
			<div>
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="lsr:MedicalValidationDate/@V"/>
				</xsl:call-template>
			</div>
		</xsl:if>
	</xsl:template>
	<xsl:template name="skrivUtTjenesteyter">
		<xsl:variable name="relationOne">
			<xsl:value-of select="lsr:RelServProv/lsr:Relation/@V"/>
		</xsl:variable>
		<xsl:for-each select="lsr:RelServProv">
			<xsl:if test="count(//lsr:RelServProv/lsr:Relation)!=count(//lsr:RelServProv/lsr:Relation[@V=$relationOne])">
				<xsl:for-each select="lsr:Relation">
					<b><xsl:call-template name="k-8254"/></b>:&#160;
				</xsl:for-each>
			</xsl:if>
			<xsl:value-of select="descendant::lsr:Name"/>
			<xsl:if test="position()!=last()"><br/></xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="skrivUtTillegg">
		<xsl:if test="lsr:Accredited">
			<xsl:choose>
				<xsl:when test="lsr:Accredited/@V='true'">Analysen er akkreditert.&#160;</xsl:when>
				<xsl:otherwise>Analysen er ikke akkreditert.&#160;</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="lsr:StructuredInfo">
			Se Strukturert resultat
			<xsl:if test="count(//lsr:ResultItem[lsr:StructuredInfo])!=1">
				<xsl:value-of select="count(//lsr:ResultItem[lsr:StructuredInfo])-count(following-sibling::lsr:ResultItem[lsr:StructuredInfo])-count(parent::lsr:ResultItem/following-sibling::lsr:ResultItem[lsr:StructuredInfo])-count(child::lsr:ResultItem[lsr:StructuredInfo])"/>
			</xsl:if>
			under.&#160;
		</xsl:if>
		<xsl:for-each select="lsr:Investigation/lsr:Comment">
			<xsl:call-template name="line-breaks">
				<xsl:with-param name="text" select="."/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="lsr:Investigation/lsr:Spec">
			<xsl:if test="//lsr:Accredited or //lsr:StructuredInfo or //lsr:Investigation/lsr:Comment or //lsr:Comment or //lsr:DiagComment or //lsr:RefAnalysedSubject or //lsr:StatusInvestigation">
				<xsl:if test="position()=1"><b>Spesifisering</b>:&#160;</xsl:if>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="contains(@S, '8212')">
					<xsl:call-template name="k-dummy-OT"/>&#160;
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="k-dummy"/>&#160;
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:for-each select="lsr:Comment">
			<xsl:if test="//lsr:Accredited or //lsr:StructuredInfo or //lsr:Investigation/lsr:Comment or //lsr:Investigation/lsr:Spec or //lsr:DiagComment or //lsr:RefAnalysedSubject or //lsr:StatusInvestigation">
				<xsl:if test="position()=1"><b>Kommentar til undersøkelsen</b>:&#160;</xsl:if>
			</xsl:if>
			<xsl:call-template name="line-breaks">
				<xsl:with-param name="text" select="."/>
			</xsl:call-template>&#160;
		</xsl:for-each>
		<xsl:for-each select="lsr:DiagComment">
			<xsl:if test="//lsr:Accredited or //lsr:StructuredInfo or //lsr:Investigation/lsr:Comment or //lsr:Investigation/lsr:Spec or //lsr:Comment or //lsr:RefAnalysedSubject or //lsr:StatusInvestigation">
				<xsl:if test="position()=1"><b>Kommentar som diagnose</b>:&#160;</xsl:if>
			</xsl:if>
			<xsl:for-each select="lsr:Concept">
				<xsl:call-template name="k-dummy"/>&#160;
			</xsl:for-each>
			<xsl:for-each select="lsr:Modifier">
				<xsl:for-each select="lsr:Name">
					<b><xsl:call-template name="k-7305"/></b>:&#160;
				</xsl:for-each>
				<xsl:for-each select="lsr:Value">
					<xsl:call-template name="k-dummy"/>
				</xsl:for-each>
			</xsl:for-each>&#160;
		</xsl:for-each>
		<xsl:for-each select="lsr:RefAnalysedSubject">
			<xsl:if test="//lsr:Accredited or //lsr:StructuredInfo or //lsr:Investigation/lsr:Comment or //lsr:Investigation/lsr:Spec or //lsr:Comment or //lsr:DiagComment or //lsr:StatusInvestigation">
				<xsl:if test="position()=1"><b>Referanse til prøve</b>:&#160;</xsl:if>
			</xsl:if>
			<xsl:call-template name="line-breaks">
				<xsl:with-param name="text" select="."/>
			</xsl:call-template>&#160;
		</xsl:for-each>
		<xsl:for-each select="lsr:StatusInvestigation">
			<xsl:if test="//lsr:Accredited or //lsr:StructuredInfo or //lsr:Investigation/lsr:Comment or //lsr:Investigation/lsr:Spec or //lsr:Comment or //lsr:DiagComment or //lsr:RefAnalysedSubject">
				<xsl:if test="position()=1"><b>Undersøkelsesstatus</b>:&#160;</xsl:if>
			</xsl:if>
			<xsl:call-template name="k-8245"/>&#160;
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
