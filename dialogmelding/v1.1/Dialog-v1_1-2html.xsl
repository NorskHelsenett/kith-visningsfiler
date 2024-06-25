<?xml version="1.0" encoding="UTF-8"?>
	<!-- Endringslogg
	-	09.08.22: v3.2.0: Semantisk HTML
	-	17.12.21: v3.1.10: Lagt til Konsultasjonstype fra icalendar sin x-servicetype
	-	04.06.21: v3.1.9: Lagt til xsl:output for å definere at output formatet skal være html
	-	01.06.21: v3.1.8: Oppdaterte xsl:import's
	-	31.05.21: v3.1.7: Tillate MimeType (vedlegg) med store bokstaver
	- 	25.03.21: v3.1.6: Lagt til TeleCom under TilknyttetEnhet.
    -   21.09.17: v3.1.4: Fjernet visning av teksten "Notat"
                          Delt opp tema og type i to separate linjer med egen overskrift
	-	09.05.17: v3.1.3: Liten formell justering av SakstypeKodet
	-	27.03.17: v3.1.2: Parameter for "visningStil". Ny stil "Smooth".
	-	06.02.17: v3.1.1: Lagt til nytt element på RollerRelatertNotat: TilknyttetEnhet
	-	25.10.16: v3.1.0: La til visningsversjonnr
	-	17.11.15: Innføring av kodeverksfil, lauotmessige justeringer og små bugfix
	-	05.05.14: Bufix og støtte for pasientrelasjon, helsepersonell og person med nyeste namespace
	-	21.02.14: Oppdatert for versjon 1.1
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
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xcal="urn:ietf:params:xml:ns:icalendar-2.0" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1" 
	xmlns:dia="http://www.kith.no/xmlstds/dialog/2013-01-23" 
	xmlns:base="http://www.kith.no/xmlstds/base64container" 
	xmlns:m1-v2_4="http://www.kith.no/xmlstds/eresept/m1/2010-05-01" 
	xmlns:m1-v2_5="http://www.kith.no/xmlstds/eresept/m1/2013-10-08" 
	xmlns:pr="http://www.kith.no/xmlstds/pasientrelasjon/2014-03-28" 
	xmlns:hcp="http://www.kith.no/xmlstds/helsepersonell/2014-03-28" 
	xmlns:pers="http://www.kith.no/xmlstds/person/2014-03-28"  
	exclude-result-prefixes="mh fk1 dia xhtml base xcal m1-v2_4 m1-v2_5 pr hcp pers">

	<xsl:import href="../../felleskomponenter/meldingshode2html.xsl"/>
	<xsl:import href="../../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../../felleskomponenter/kodeverk.xsl"/>
	<xsl:import href="../../felleskomponenter/visningstil.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<!-- Variabel for standard antall kolonner i tabellene-->
	<xsl:variable name="std-col" select="8"/>
	<xsl:variable name="std-td" select="100"/>
	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'dialog1.1 - v3.2.0'"/>
	
	<xsl:variable name="IsTestMessage" select="boolean(/mh:MsgHead/mh:MsgInfo/mh:ProcessingStatus[@V = 'D'])" />
	
	<xsl:template match="/">
		<html>
			<head>
				<title>Dialogmelding</title>
				<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
				<style type="text/css">
					<xsl:value-of select="document('../../felleskomponenter/KITH-visning.css')" disable-output-escaping="yes"/>
				</style>
				<style type="text/css">
					<xsl:value-of select="document('../../felleskomponenter/smooth-visning.css')" disable-output-escaping="yes"/>
				</style>
			</head>
			<body>
				<xsl:if test="$IsTestMessage">
					<p class="TestMessageWarning">OBS: Dette er en testmelding.</p>
				</xsl:if>
				<xsl:apply-templates select="mh:MsgHead"/>
			</body>
		</html>
	</xsl:template>
	
	<!-- Template som kalles fra BunnTillegg i meldingshodet. Kan brukes til visning av egenkomponert bunn -->
	<xsl:template name="EgetBunnTillegg">
	</xsl:template>
	
	<!-- Visning av meldingshodet. Tilpasset vinduskonvolutt ved utskrift -->
	<xsl:template match="mh:MsgHead">
		<xsl:call-template name="Topp"/>
		<xsl:call-template name="Innhold"/>
		<xsl:call-template name="BunnTillegg">
			<xsl:with-param name="stil" select="$stil"/>
			<xsl:with-param name="versjon" select="$versjon"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="Innhold" match="dia:Dialogmelding">
		<main class="{$stil}">
			<h1>
				<xsl:for-each select="//mh:MsgInfo/mh:Type">
					<xsl:call-template name="k-8279"/>
				</xsl:for-each>
			</h1>
			<xsl:if test="//mh:Document[position()=1]/mh:ContentDescription or //dia:SakstypeKodet or //dia:Sakstype">
				<table>
					<tbody>
						<tr>
							<xsl:for-each select="//mh:Document[position()=1]/mh:ContentDescription">
								<th>Beskrivelse</th>
								<td><xsl:value-of select="."/></td>
							</xsl:for-each>
							<xsl:if test="//dia:SakstypeKodet or //dia:Sakstype">
								<th>Sakstype</th>
								<td>
									<xsl:if test="//dia:SakstypeKodet">
										<b>
											<xsl:value-of select="/descendant::dia:SakstypeKodet[1]/@V"/>&#160;
										</b>
										<xsl:if test="contains(/descendant::dia:SakstypeKodet[1]/@S, '7170')">(ICPC)</xsl:if>
										<xsl:if test="contains(/descendant::dia:SakstypeKodet[1]/@S, '7110')">(ICD-10)</xsl:if>
										<xsl:if test="contains(/descendant::dia:SakstypeKodet[1]/@S, '7250')">(ICF)</xsl:if>
										<br/>
									</xsl:if>
									<xsl:value-of select="/descendant::dia:Sakstype[1]"/>
								</td>
							</xsl:if>
						</tr>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Notat -->
		    <!-- <xsl:if test="((//dia:Notat) and ( //mh:MsgInfo/mh:Type/@V != 'DIALOG_HELSEFAGLIG'))" >
			<xsl:if test="//dia:Notat" >
				<h2>Notat</h2>
			</xsl:if>-->
			<xsl:if test="//dia:Notat">
				<table>
					<tbody>
						<xsl:apply-templates select="//dia:Notat"/>
					</tbody>
				</table>
			</xsl:if>
			<!-- Overskrift og tabell for Foresporsel -->
			<xsl:for-each select="//dia:Foresporsel">
				<section>
					<h2>
						<xsl:choose>
							<xsl:when test="//mh:MsgInfo/mh:Type/@V='DIALOG_SVAR'">Opprinnelig forespørsel</xsl:when>
							<xsl:when test="local-name(..)='Notat'">Opprinnelig forespørsel</xsl:when>
							<xsl:otherwise>Forespørsel</xsl:otherwise>
						</xsl:choose>
					</h2>
					<table>
						<tbody>
							<xsl:apply-templates select="."/>
						</tbody>
					</table>
				</section>
			</xsl:for-each>
			<!-- Overskrift og tabell for Roller -->
			<xsl:if test="//dia:RollerRelatertNotat">
				<section>
					<h2>Kontaktopplysninger</h2>
					<table>
						<tbody>
							<xsl:apply-templates select="//dia:RollerRelatertNotat"/>
						</tbody>
					</table>
				</section>
			</xsl:if>
			<!-- Overskrift og tabell for vedlagte dokument -->
			<xsl:for-each select="//mh:Document[position()!=1 and not(.//m1-v2_4:Resept or .//m1-v2_5:Resept)]">
				<section>
					<h2>
						<xsl:choose>
							<xsl:when test=".//xcal:icalendar">Informasjon om timer</xsl:when>
							<xsl:when test=".//pr:Pasientrelasjon">Annen&#160;pasientrelasjon</xsl:when>
							<xsl:when test=".//hcp:Helsepersonell">Annen&#160;behandler</xsl:when>
							<xsl:when test=".//pers:Personer">Vedlagte&#160;personer</xsl:when>
							<xsl:otherwise>Vedlegg</xsl:otherwise>
						</xsl:choose>
					</h2>
					<table>
						<tbody>
							<xsl:apply-templates select="mh:RefDoc"/>
						</tbody>
					</table>
				</section>
			</xsl:for-each>
			<!-- Overskrift og tabell for vedlagte resepter -->
			<xsl:for-each select="//mh:Document[position()!=1 and (.//m1-v2_4:Resept or .//m1-v2_5:Resept)]">
				<xsl:if test=".//m1-v2_4:Resept">
					<xsl:apply-templates select=".//m1-v2_4:Resept"/>
				</xsl:if>
				<xsl:if test=".//m1-v2_5:Resept">
					<xsl:apply-templates select=".//m1-v2_5:Resept"/>
				</xsl:if>
			</xsl:for-each>
		</main>
	</xsl:template>
	
	<xsl:template match="dia:Foresporsel">
		<xsl:if test="dia:TypeForesp or dia:Hastegrad">
			<tr>
				<xsl:if test="dia:TypeForesp">
					<th width="20%">Type</th>
					<td>
						<xsl:for-each select="dia:TypeForesp">
							<xsl:choose>
								<xsl:when test="contains(@S,'9065')"><xsl:call-template name="k-9065"/></xsl:when>
								<xsl:when test="contains(@S,'8331')"><xsl:call-template name="k-8331"/></xsl:when>
								<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="dia:Hastegrad">
					<th width="20%">Hastegrad</th>
					<td>
						<xsl:for-each select="dia:Hastegrad">
							<xsl:call-template name="k-9067"/>
						</xsl:for-each>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="dia:Formål or dia:Begrunnelse">
			<tr>
				<xsl:if test="dia:Formål">
					<th width="20%">Formål</th>
					<td>
						<xsl:for-each select="dia:Formål">
							<xsl:choose>
								<xsl:when test="contains(@S,'9068')"><xsl:call-template name="k-9068"/></xsl:when>
								<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="dia:Begrunnelse">
					<th width="20%">Utdyping av formål</th>
					<td>
						<xsl:value-of select="dia:Begrunnelse"/>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="dia:TypeJournalinfo">
			<tr>
				<th width="20%">Type journalinformasjon</th>
				<td colspan="3">
					<xsl:for-each select="dia:TypeJournalinfo">
						<div>
							<xsl:choose>
								<xsl:when test="contains(@S,'9066')"><xsl:call-template name="k-9066"/></xsl:when>
								<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
							</xsl:choose>
						</div>
					</xsl:for-each>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="dia:FraDato or dia:TilDato">
			<tr>
				<xsl:if test="dia:FraDato">
					<th width="20%">Fra dato</th>
					<td>
						<xsl:value-of select="dia:FraDato"/>
					</td>
				</xsl:if>
				<xsl:if test="dia:TilDato">
					<th width="20%">Til dato</th>
					<td>
						<xsl:value-of select="dia:TilDato"/>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="dia:EmneSporsmal or dia:KodetOpplysning">
			<tr>
				<xsl:if test="dia:EmneSporsmal">
					<th width="20%">Emne spørsmål</th>
					<td>
						<xsl:value-of select="dia:EmneSporsmal"/>
					</td>
				</xsl:if>
				<xsl:if test="dia:KodetOpplysning">
					<th width="20%">Annen opplysning</th>
					<td>
						<xsl:if test="dia:KodetOpplysning/@DN"><xsl:value-of select="dia:KodetOpplysning/@DN"/></xsl:if>&#160;
						<xsl:if test="dia:KodetOpplysning/@OT"><xsl:value-of select="dia:KodetOpplysning/@OT"/></xsl:if>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="dia:Sporsmal">
			<tr>
				<th width="20%">Spørsmål</th>
				<td colspan="3">
					<xsl:for-each select="dia:Sporsmal">
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
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
	
	
	<xsl:template match="dia:Notat">
	    <xsl:if test="dia:TemaKodet">
			<tr>
				<th width="20%">
					<xsl:choose>
						<xsl:when test="//mh:Type/@V='DIALOG_STATUS_HENVISNING'">Status</xsl:when>
						<xsl:otherwise>Type</xsl:otherwise>
					</xsl:choose>
				</th>
				<td colspan="3">
					<xsl:for-each select="dia:TemaKodet">
						<xsl:choose>
							<xsl:when test="contains(@S,'7321')"><xsl:call-template name="k-7321"/></xsl:when>
							<xsl:when test="contains(@S,'8117')"><xsl:call-template name="k-8117"/></xsl:when>
							<xsl:when test="contains(@S,'9069')"><xsl:call-template name="k-9069"/></xsl:when>
							<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="dia:Tema">
			<tr>
				<th width="20%">Tema</th>
				<td colspan="3">
					<xsl:value-of select="dia:Tema"/>
				</td>
			</tr>
		</xsl:if>   
		<xsl:if test="dia:TekstNotatInnhold">
			<tr>
				<th width="20%">Innhold</th>
				<td colspan="3">
					<xsl:for-each select="dia:TekstNotatInnhold">
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
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="dia:DatoNotat or dia:Merknad">
			<tr>
				<xsl:if test="dia:DatoNotat">
					<th width="20%">Dato for notat</th>
					<td colspan="3">
						<xsl:value-of select="dia:DatoNotat"/>
					</td>
				</xsl:if>
				<xsl:if test="dia:Merknad">
					<th width="20%">Merknad</th>
					<td>
						<xsl:value-of select="dia:Merknad"/>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="dia:RollerRelatertNotat">
		<tr>
			<th>
				<xsl:for-each select="dia:RoleToPatient">
					<xsl:if test="position()&gt;1">,&#160;</xsl:if>
					<xsl:choose>
						<xsl:when test="contains(@S,'9034')"><xsl:call-template name="k-9034"/></xsl:when>
						<xsl:when test="contains(@S,'8422')"><xsl:call-template name="k-8422"/></xsl:when>
						<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				<xsl:if test="dia:RoleToPatient and dia:RolleNotat">,&#160;</xsl:if>
				<xsl:for-each select="dia:RolleNotat">
					<xsl:choose>
						<xsl:when test="contains(@S,'9057')"><xsl:call-template name="k-9057"/></xsl:when>
						<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</th>
			<td>
				<!-- choice :-->
				<xsl:for-each select="dia:HealthcareProfessional">
					<xsl:call-template name="HealthcareProfessional"/>
				</xsl:for-each>
				<xsl:for-each select="dia:Person">
					<xsl:call-template name="Person"/>
				</xsl:for-each>
			</td>
		</tr>
		<tr>
			<xsl:apply-templates select="dia:TilknyttetEnhet" /> <!-- maxOccurs="1" -->
		</tr>
	</xsl:template>

	<xsl:template match="dia:TilknyttetEnhet">
		<th>
			Tilknyttet enhet
		</th>
		<td>
			<div>
				<xsl:for-each select="dia:Kontaktenhet">
					<xsl:call-template name="dia:Organisation"/>
				</xsl:for-each>
			</div>
			<div>
				<xsl:for-each select="dia:HealthcareProfessional">
					<xsl:call-template name="HealthcareProfessional"/>
				</xsl:for-each>
				<xsl:for-each select="dia:Person">
					<xsl:call-template name="Person"/>
				</xsl:for-each>
			</div>
			<xsl:if test="dia:Merknad">
				<div>
					<b>Merknad: </b>
					<xsl:value-of select="dia:Merknad" />
				</div>
			</xsl:if>
		</td>
	</xsl:template>

	<xsl:template name="dia:Organisation">
		<div>
			<xsl:value-of select="child::*[local-name()='OrganisationName']"/>
		</div>

		<div>
			<xsl:if test="fk1:Ident">
				<b>
					<xsl:for-each select="fk1:Ident/fk1:TypeId">
						<xsl:call-template name="k-9051"/>
					</xsl:for-each>&#160;
				</b>
				<xsl:value-of select="fk1:Ident/fk1:Id"/>
			</xsl:if>
			<xsl:for-each select="fk1:Address">, 
				<xsl:call-template name="fk1:Address"/>	
			</xsl:for-each>
			<xsl:for-each select="fk1:TeleCom">, 
				<xsl:call-template name="fk1:TeleCom"/>	
			</xsl:for-each>
		</div>
			
	</xsl:template>

	<xsl:template name="fk1:Address">
		<b>
			<xsl:choose>
				<xsl:when test="child::*[local-name()='Type']">
					<xsl:for-each select="child::*[local-name()='Type']">
						<xsl:call-template name="k-3401"/>
					</xsl:for-each>&#160;
				</xsl:when>
				<xsl:otherwise>Adresse </xsl:otherwise>
			</xsl:choose>
		</b>
		<xsl:if test="child::*[local-name()='StreetAdr']">
			<xsl:value-of select="child::*[local-name()='StreetAdr']"/>,&#160;</xsl:if>
		<xsl:if test="child::*[local-name()='PostalCode']">
			<xsl:value-of select="child::*[local-name()='PostalCode']"/>
		</xsl:if>
		<xsl:if test="child::*[local-name()='City']">&#160;<xsl:value-of select="child::*[local-name()='City']"/>
		</xsl:if>
		<xsl:if test="child::*[local-name()='CityDistr']">, <xsl:for-each select="child::*[local-name()='CityDistr']">
				<xsl:call-template name="k-3403"/>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="child::*[local-name()='County']">, <xsl:for-each select="child::*[local-name()='County']">
				<xsl:call-template name="k-3402"/>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Country']">, <xsl:for-each select="child::*[local-name()='Country']">
				<xsl:call-template name="k-9043"/>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<!-- Telekommunikasjon -->
	<xsl:template match="fk1:TeleCom" name="fk1:TeleCom">
		<xsl:for-each select="child::*[local-name()=&quot;TeleAddress&quot;]">
			<xsl:call-template name="TeleAddress"/>
		</xsl:for-each>
	</xsl:template>
	<!-- Telekommunikasjon -->
	<xsl:template match="fk1:TeleAddress" name="TeleAddress">
		<xsl:choose>
			<xsl:when test="starts-with(@V, &quot;tel:&quot;) or starts-with(@V, &quot;callto:&quot;)">
				<div>
					<b>Telefon:</b>&#160;<xsl:value-of select="substring-after(@V, &quot;:&quot;)"/>&#160;
				</div>
			</xsl:when>
			<xsl:when test="starts-with(@V, &quot;fax:&quot;)">
				<div>
					<b>Fax:</b>&#160;<xsl:value-of select="substring-after(@V, &quot;:&quot;)"/>&#160;
				</div>
			</xsl:when>
			<xsl:when test="starts-with(@V, &quot;mailto:&quot;)">
				<div>
					<b>e-post:</b>&#160;<xsl:value-of select="substring-after(@V, &quot;:&quot;)"/>&#160;
				</div>
			</xsl:when>
			<xsl:when test="starts-with(@V, &quot;http:&quot;)">
				<div>
					<b>Web:</b>&#160;<xsl:value-of select="@V"/>&#160;
				</div>
			</xsl:when>
			<!-- Bruker axis her for bruk både i fk1: og mh: namespace -->
			<xsl:when test="preceding-sibling::*/@DN">
				<div>
					<b>
						<xsl:value-of select="preceding-sibling::*/@DN"/>:
					</b>&#160;<xsl:value-of select="@V"/>
				</div>
			</xsl:when>
			<xsl:when test="preceding-sibling::*/@V">
				<div>
					<b>
						<xsl:for-each select="preceding-sibling::*">
							<xsl:call-template name="k-9061"/>:
						</xsl:for-each>
					</b>&#160;<xsl:value-of select="@V"/>
				</div>
			</xsl:when>
			<xsl:when test="contains(@V, &quot;:&quot;)">
				<div>
					<b>Kontakt:</b>&#160;<xsl:value-of select="substring-after(@V, &quot;:&quot;)"/>&#160;
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div>
					<b>Kontakt:</b>&#160;<xsl:value-of select="@V"/>&#160;
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="mh:RefDoc">
		<xsl:if test="mh:MsgType or mh:Id or mh:IssueDate or mh:MimeType or mh:Compression">
			<tr>
				<xsl:if test="mh:MsgType">
					<th>Type</th>
					<td width="{((($std-col)-2)*number(not(mh:Id | mh:IssueDate | mh:MimeType | mh:Compression))+1)*$std-td}px" colspan="{(($std-col)-2)*number(not(mh:Id | mh:IssueDate | mh:MimeType | mh:Compression))+1}">
						<xsl:for-each select="mh:MsgType">
							<xsl:call-template name="k-8114"/>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="mh:Id">
					<th>Id</th>
					<td width="{((($std-col)-2-count(mh:MsgType)*2)*number(not(mh:IssueDate | mh:MimeType | mh:Compression))+1)*$std-td}px" colspan="{(($std-col)-2-count(mh:MsgType)*2)*number(not(mh:IssueDate | mh:MimeType | mh:Compression))+1}">
						<xsl:value-of select="mh:Id"/>
					</td>
				</xsl:if>
				<xsl:if test="mh:IssueDate">
					<th>Utstedt-dato</th>
					<td width="{((($std-col)-2-count(mh:MsgType | mh:Id)*2)*number(not(mh:MimeType | mh:Compression))+1)*$std-td}px" colspan="{(($std-col)-2-count(mh:MsgType | mh:Id)*2)*number(not(mh:MimeType | mh:Compression))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="mh:IssueDate/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="mh:MimeType">
					<th>Mimetype</th>
					<td width="{((($std-col)-2-count(mh:MsgType | mh:Id | mh:IssueDate)*2)*number(not(mh:Compression))+1)*$std-td}px" colspan="{(($std-col)-2-count(mh:MsgType | mh:Id | mh:IssueDate)*2)*number(not(mh:Compression))+1}">
						<xsl:value-of select="mh:MimeType"/>
					</td>
				</xsl:if>
				<xsl:if test="mh:Compression">
					<th>Komprimering</th>
					<td colspan="{($std-col)-1-count(mh:MsgType | mh:Id | mh:IssueDate | mh:MimeType)*2}">
						<xsl:for-each select="mh:Compression">
							<xsl:call-template name="k-1204"/>
						</xsl:for-each>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="mh:Description">
			<tr>
				<th>Beskrivelse</th>
				<td colspan="{($std-col)-1}">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="mh:Description"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="mh:Content or mh:FileReference">
			<xsl:choose>
				<xsl:when test="contains(mh:MimeType,'image')">
					<tr>
						<th>Bilde</th>
						<xsl:choose>
							<xsl:when test="mh:FileReference">
								<td colspan="{($std-col)-1}">
									<img>
										<xsl:attribute name="src"><xsl:value-of select="mh:FileReference"/></xsl:attribute>
										<xsl:attribute name="alt">Bilde fra ekstern URL</xsl:attribute>
									</img>
								</td>
							</xsl:when>
							<xsl:when test="mh:Content">
								<td colspan="{($std-col)-1}">
									<xsl:choose>
										<xsl:when test="mh:Content/base:Base64Container">
											<img>
												<xsl:attribute name="src"><xsl:value-of select="concat('data:',mh:MimeType,';base64,',mh:Content/base:Base64Container)"/></xsl:attribute>
												<xsl:attribute name="alt">Bilde vedlagt som base64-kode</xsl:attribute>
											</img>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="mh:Content"/>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:when>
						</xsl:choose>
					</tr>
				</xsl:when>
				<xsl:when test="contains(mh:MimeType,'pdf') or contains(mh:MimeType,'PDF')">
					<tr>
						<th>pdf</th>
						<xsl:choose>
							<xsl:when test="mh:FileReference">
								<td colspan="{($std-col)-1}">
									<object>
										<xsl:attribute name="data"><xsl:value-of select="concat(mh:FileReference,'&#35;view&#61;FitH&#38;toolbar&#61;1')"/></xsl:attribute>
										<xsl:attribute name="type">application/pdf</xsl:attribute>
										<xsl:attribute name="width">100%</xsl:attribute>
										<xsl:attribute name="height">500px</xsl:attribute>
									</object>
								</td>
							</xsl:when>
							<xsl:when test="mh:Content">
								<td colspan="{($std-col)-1}">
									<xsl:choose>
										<xsl:when test="mh:Content/base:Base64Container">
											<object>
												<xsl:attribute name="data"><xsl:value-of select="concat('data:application/pdf;base64,',mh:Content/base:Base64Container)"/></xsl:attribute>
												<xsl:attribute name="type">application/pdf</xsl:attribute>
												<xsl:attribute name="width">100%</xsl:attribute>
												<xsl:attribute name="height">500px</xsl:attribute>
												<p> <!-- Denne paragrafen blir aktivert når pdf-visningen feiler - f.eks. med InternetExplorer -->
												<b>Visning av vedlagte pdf-fil feilet.</b>
												<br/>
												Vanligste årsak er bruk av Internet Explorer, eller manglende plug-in.
											</p>
											</object>
											<!-- <p> Denne paragrafen blir aktivert når pdf-visningen feiler - f.eks. med InternetExplorer 
												<b>Visning av vedlagte pdf-fil feilet.</b><br/>
												Vanligste årsak er bruk av Internet Explorer, eller manglende plug-in.
											</p> -->
											
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="mh:Content"/>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:when>
						</xsl:choose>
					</tr>
				</xsl:when>
				<xsl:when test=".//xcal:icalendar">
					<xsl:if test=".//xcal:vevent">
						<xsl:variable name="antallTimer" select="count(.//xcal:vevent)"/>
						<xsl:for-each select=".//xcal:vevent">
							<xsl:if test="position()=1">
								<tr>
									<th rowspan="{($antallTimer+1)}">Tidspunkt</th>
									<th>Start</th>
									<th>Slutt</th>
									<th colspan="{($std-col)-3}">Legens&#160;HER-Id</th>
								</tr>
							</xsl:if>
							<tr>
								<td><xsl:call-template name="skrivUtDateTime"><xsl:with-param name="oppgittTid" select=".//xcal:dtstart/xcal:date-time"/></xsl:call-template></td>
								<td><xsl:call-template name="skrivUtDateTime"><xsl:with-param name="oppgittTid" select=".//xcal:dtend/xcal:date-time"/></xsl:call-template></td>
								<td colspan="{($std-col)-3}"><xsl:value-of select=".//xcal:contact/xcal:text"/></td>
							</tr>
							<xsl:if test=".//xcal:x-servicetype">
								<tr>                  
									<th>Konsultasjonstype</th>
									<td colspan="{($std-col)-3}">
										<xsl:choose>
											<xsl:when test="substring-before(//xcal:x-servicetype/xcal:text, ':') = 9505">
												<xsl:call-template name="k-9505">
													<xsl:with-param name="V" select="substring-after(//xcal:x-servicetype/xcal:text, ':')" />
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="//xcal:x-servicetype/xcal:text"/>
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</tr>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
					<xsl:if test=".//xcal:description">
						<tr>
							<th>Beskrivelse</th>
							<td colspan="{($std-col)-1}"><xsl:value-of select="//xcal:description/xcal:text"/></td>
						</tr>
					</xsl:if>
					<xsl:if test=".//xcal:summary">
						<tr>
							<th>Sammendrag</th>
							<td colspan="{($std-col)-1}"><xsl:value-of select="//xcal:summary/xcal:text"/></td>
						</tr>
					</xsl:if>
				</xsl:when>
				<xsl:when test=".//pr:Pasientrelasjon">
					<tr>
						<th>
							<xsl:choose>
								<xsl:when test=".//pr:Pasientrelasjon/pr:Relasjon"><xsl:value-of select=".//pr:Pasientrelasjon/pr:Relasjon/@DN"/></xsl:when>
								<xsl:otherwise>Person</xsl:otherwise>
							</xsl:choose>
						</th>
							<td colspan="{($std-col)-1}">
							<xsl:for-each select=".//pr:Person">
								<xsl:call-template name="Person"/>
							</xsl:for-each>
						</td>
					</tr>
				</xsl:when>
				<xsl:when test=".//hcp:Helsepersonell">
					<tr>
						<th>Helsepersonell</th>
						<td colspan="{($std-col)-1}">
							<xsl:for-each select=".//hcp:Helsepersonell">
								<xsl:call-template name="HealthcareProfessional"/>
							</xsl:for-each>
						</td>
					</tr>
				</xsl:when>
				<xsl:otherwise>
					<tr>
						<td colspan="{($std-col)-1}">
							<xsl:choose>
								<xsl:when test="mh:Content">
									<xsl:value-of select="mh:Content"/>
								</xsl:when>
								<xsl:when test="mh:FileReference">
									<xsl:value-of select="mh:FileReference"/>
								</xsl:when>
							</xsl:choose>
						</td>
					</tr>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
