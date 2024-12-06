<?xml version="1.0" encoding="UTF-8"?>
	<!-- Endringslogg
	- 05.09.24: TilleggsopplysningPasient, SivilStatus kodeverk endret til 3103
	- 17.10.23: Tydeliggjøring av Behov for Tolk - Språk
	- 04.05.23: Forbedre lesbarhet i KartlagtFunksjon (InfoKartleggingFunksjonsniva) når det er lagt inn merknader til verdiene
	- 09.08.22: Semantisk HTML (endre <span class="strong"> til <b>)
	- 04.06.21: Lagt til xsl:output for å definere at output formatet skal være html
	- 08.04.21: Endre <span> til <div>, siden block-elementer (<ul>) inni inline-elementer (<span>) kan gi feil visning.
	- 19.09.19: Flytt div innenfor if PrivatTjeneste = true for å få riktig html-struktur
    - 23.08.17: Korrigert fra <div class="eh-ool-1"> til <div class="eh-col-1"> på 4 plasser samt fjernet overflødige ">"
	- 02.12.15: Innføring av felles kodeverksfil. Småjusteringer på layout.
	- 01.12.15: Omskrivning av fila for å unngå bruk av po-navnerommet. Dette for at flere ulike versjoner av plo-meldingene kan bruke fila.
	-->
	<!-- Om
	- Inngår i Hdirs visningsfiler versjon 2.0
	- Laget i XMLSpy v2016 (http://www.altova.com) av Jan Sigurd Dragsjø (nhn.no)
	-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1" exclude-result-prefixes="fk1">

	<!-- Filer som må importeres. Vanligvis gjøres dette i hovedfila som importerer denne komponentfila. Derfor er de kommentert ut. -->
	<xsl:import href="funksjoner.xsl"/>
	<xsl:import href="meldingshode2html.xsl"/>
	<xsl:import href="kodeverk.xsl"/>
	<xsl:import href="cave2html.xsl"/>
	<xsl:import href="journalnotat2html.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<!-- Variabel for standard antall kolonner i tabellene-->
	<xsl:variable name="std-col" select="8"/>
	<xsl:variable name="std-td" select="100"/>


	<!-- Visning av innhold i Pårørende/foresatt -->
	<xsl:template name="ParorendeForesatt">
		<xsl:param name="stripedCss" />
		<div class="eh-row-4">
			<div class="eh-col-1 {$stripedCss}">
				<div class="eh-label">
					<xsl:for-each select="child::*[local-name()='Slektskap']">
						<xsl:call-template name="k-9033"/>&#160;
					</xsl:for-each>
					<xsl:if test="child::*[local-name()='Slektskap'] and child::*[local-name()='Omsorgsfunksjon']">og&#160;</xsl:if>
					<xsl:for-each select="child::*[local-name()='Omsorgsfunksjon']">
						<xsl:call-template name="k-9050"/>&#160;
					</xsl:for-each>
					<xsl:if test="not(child::*[local-name()='Slektskap']) and not(child::*[local-name()='Omsorgsfunksjon'])">Pårørende/foresatt</xsl:if>
				</div>
				<div class="eh-field">
					<xsl:for-each select="child::*[local-name()='Referanseperson']">
						<div><xsl:value-of select="fk1:FamilyName"/>,&#160;<xsl:value-of select="fk1:GivenName"/>&#160;<xsl:value-of select="fk1:MiddleName"/></div>
					</xsl:for-each>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='Referanseperson']//fk1:TeleAddress">
				<div class="eh-col-1 {$stripedCss}">
					<div class="eh-label">Tele</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='Referanseperson']//fk1:TeleAddress"><xsl:call-template name="TeleAddress"/></xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='FodselsarMindrearigParorende']">
				<div class="eh-col-1 {$stripedCss}">
					<div class="eh-label">Født</div>
					<div class="eh-field">
						<xsl:value-of select="child::*[local-name()='FodselsarMindrearigParorende']"/>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Merknad']">
				<div class="eh-col-1 eh-last-child {$stripedCss}">
					<div class="eh-label">Merknad</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Tilknyttet Enhet -->
	<xsl:template name="TilknyttetEnhet">
		<xsl:param name="stripedCss" />
		<div class="eh-row-4">
			<div class="eh-col-1 {$stripedCss}">
				<div class="eh-label">Kontaktenhet</div>
				<div class="eh-field inline-content">
					<xsl:for-each select="//child::*[local-name()='TilknyttetEnhet']/child::*[local-name()='Kontaktenhet']">	<!-- maxOccurs="1" -->
						<xsl:call-template name="Organisation"/>
					</xsl:for-each>
				</div>
			</div>
			<xsl:if test="//child::*[local-name()='TilknyttetEnhet']/child::*[local-name()='Merknad']">
				<div class="eh-col-1 eh-last-child {$stripedCss}">
					<div class="eh-label">Merknad</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="//child::*[local-name()='TilknyttetEnhet']/child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Kontaktperson helsepersonell -->
	<xsl:template name="KontaktpersonHelsepersonell">
		<xsl:param name="stripedCss" />
		<div class="eh-row-4">
			<div class="eh-col-1 {$stripedCss}">
				<div class="eh-label">Kontaktperson</div>
				<div class="eh-field inline-content">
					<xsl:for-each select="child::*[local-name()='Kontaktperson']">
						<xsl:call-template name="HealthcareProfessional"/>
					</xsl:for-each>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='Merknad']">
				<div class="eh-col-1 eh-last-child {$stripedCss}">
					<div class="eh-label">Merknad</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Tilleggsopplysninger pasient -->
	<xsl:template name="TilleggsopplysningPasient">
		<div class="eh-row-4">
			<xsl:if test="child::*[local-name()='SivilStatus']">
				<div class="eh-col-1">
					<div class="eh-label">SivilStatus</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='SivilStatus']">
							<xsl:call-template name="k-3103"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='BorAlene']">
				<div class="eh-col-1">
					<div class="eh-label">Bor alene</div>
					<div class="eh-field">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='BorAlene']='true'">Ja</xsl:when>
							<xsl:otherwise>Nei</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Sprak']">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label">Språk</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='Sprak']">
							<xsl:call-template name="k-3303"/>&#160;
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Sendt dokument -->
	<xsl:template name="SendtDokument">
		<xsl:param name="stripedCss" />
		<div class="eh-row-4">
			<div class="eh-col-1 {$stripedCss}">
				<div class="eh-label">
					<xsl:for-each select="child::*[local-name()='Opplysning']">
						<xsl:choose>
							<xsl:when test="contains(@S, '8329')"><xsl:call-template name="k-8329"/>&#160;</xsl:when>
							<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
						</xsl:choose>&#160;
					</xsl:for-each>
				</div>
				<div class="eh-field">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='JaNei']='true' and child::*[local-name()='DatoSendt']">
							<b>Sendt</b>&#160;
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='DatoSendt']"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="child::*[local-name()='JaNei']='true' and not(child::*[local-name()='DatoSendt'])">
							<b>Sendt:</b>&#160;Ja
						</xsl:when>
						<xsl:when test="child::*[local-name()='JaNei']='false' and child::*[local-name()='DatoSendt']">
							<b>Sendes</b>&#160;
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='DatoSendt']"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="child::*[local-name()='JaNei']='false' and not(child::*[local-name()='DatoSendt'])">
							<b>Sendt:</b>&#160;Nei
						</xsl:when>
					</xsl:choose>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='TypeMottaker'] or child::*[local-name()='NavnMottaker']">
				<div class="eh-col-1 {$stripedCss}">
					<div class="eh-label">Mottaker</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='TypeMottaker']">
							<xsl:choose>
								<xsl:when test="contains(@S, '8330')"><xsl:call-template name="k-8330"/>&#160;</xsl:when>
								<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
							</xsl:choose>&#160;
						</xsl:for-each>
						<xsl:value-of select="child::*[local-name()='NavnMottaker']"/>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Merknad']">
				<div class="eh-col-1 eh-last-child {$stripedCss}">
					<div class="eh-label">Merknad</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Informasjon om forsendelsen -->
	<xsl:template name="InformasjonOmForsendelsen">
		<div class="eh-col-1">
			<div class="eh-label">Meldingsstatus</div>
			<div class="eh-field">
				<xsl:for-each select="child::*[local-name()='Forsendelsesstatus']">
					<xsl:call-template name="k-7309"/>
				</xsl:for-each>
			</div>
		</div>
		<!-- <xsl:if test="child::*[local-name()='ForbeholdOmVideresending']">
			<div class="eh-col-1">
				<div class="eh-label">Forbehold gitt om videresending</div>
				<div class="eh-field">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='ForbeholdOmVideresending']='true'">Ja</xsl:when>
						<xsl:otherwise>Nei</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</xsl:if> -->
		<xsl:if test="child::*[local-name()='SvarPaaForesporsel']">
			<div class="eh-col-1">
				<div class="eh-label">Svar på forespørsel</div>
				<div class="eh-field">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='SvarPaaForesporsel']='true'">Ja</xsl:when>
						<xsl:otherwise>Nei</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</xsl:if>
		<!-- <xsl:if test="//child::*[local-name()='InnholdKonsultasjon']/child::*[local-name()='Merknad'] or //child::*[local-name()='TypeInnholdIMelding']/child::*[local-name()='Merknad']">
			<div class="eh-col-1">
				<div class="eh-label">Merknad til innhold</div>
				<div class="eh-field">
					<xsl:for-each select="//child::*[local-name()='InnholdKonsultasjon']/child::*[local-name()='Merknad']">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="."/>
						</xsl:call-template>
					</xsl:for-each>
					<xsl:for-each select="//child::*[local-name()='TypeInnholdIMelding']/child::*[local-name()='Merknad']">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="."/>
						</xsl:call-template>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if> -->
		<!-- <xsl:for-each select="child::*[local-name()='Foresporsel']">
			<xsl:call-template name="Foresporsel"/>
		</xsl:for-each> -->
	</xsl:template>

	<!-- Visning av innhold i Ansvar for rapport -->
	<xsl:template name="AnsvarForRapport">
		<xsl:param  name="stripedCss" />
		<div class="eh-row-4">
			<div class="eh-col-1 {$stripedCss}">
				<div class="eh-label">
					<xsl:if test="child::*[local-name()='TypeRelasjon']">
						<xsl:for-each select="child::*[local-name()='TypeRelasjon']">
							<xsl:choose>
								<xsl:when test="contains(@S, '8254')"><xsl:call-template name="k-8254"/>&#160;</xsl:when>
								<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
							</xsl:choose>&#160;
						</xsl:for-each>
					</xsl:if>&#160;
				</div>
				<div class="eh-field inline-content">
						<xsl:for-each select="child::*[local-name()='AnsvarligRapport']">
							<xsl:call-template name="HealthcareProfessional"/>
						</xsl:for-each>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='GodkjentDato']">
				<div class="eh-col-1 {$stripedCss}">
					<div class="eh-label">Godkjent</div>
					<div class="eh-field">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="child::*[local-name()='GodkjentDato']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Merknad']">
				<div class="eh-col-1 eh-last-child {$stripedCss}">
					<div class="eh-label">Merknad</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Forespørsel -->
	<xsl:template name="Foresporsel">
		<div class="eh-col-1">
			<div class="eh-label">
				Opprinnelig forespørsel:
				<xsl:for-each select="child::*[local-name()='TypeForesp']">
					<xsl:choose>
						<xsl:when test="contains(@S, '9152')"><xsl:call-template name="k-9152"/></xsl:when>
						<xsl:when test="contains(@S, '9153')"><xsl:call-template name="k-9153"/></xsl:when>
						<xsl:when test="contains(@S, '9154')"><xsl:call-template name="k-9154"/></xsl:when>
						<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</div>
			<div class="eh-field">
				<xsl:if test="child::*[local-name()='Sporsmal']">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="child::*[local-name()='Sporsmal']"/>
					</xsl:call-template>
				</xsl:if>&#160;
			</div>
		</div>
		<xsl:if test="child::*[local-name()='Formål'] or child::*[local-name()='Begrunnelse'] or child::*[local-name()='TypeJournalinfo']">
			<div class="eh-col-1">
				<div class="eh-label">Formål</div>
				<div class="eh-field">
					<xsl:for-each select="child::*[local-name()='Formål']">
						<xsl:choose>
							<xsl:when test="contains(@S, '9065')"><xsl:call-template name="k-9065"/></xsl:when>
							<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
					<xsl:if test="child::*[local-name()='Begrunnelse']">
						<br />
						<b>Begrunnelse:</b>
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Begrunnelse']"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="child::*[local-name()='TypeJournalinfo']">
						<br />
						<b>Kategori:</b>
						<xsl:for-each select="child::*[local-name()='TypeJournalinfo']">
							<xsl:call-template name="k-9066"/>
						</xsl:for-each>
					</xsl:if>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Hastegrad']">
			<div class="eh-col-1">
				<div class="eh-label">Hastegrad</div>
				<div class="eh-field">
					<xsl:for-each select="child::*[local-name()='Hastegrad']">
						<xsl:call-template name="k-9067"/>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='FraDato']">
			<div class="eh-col-1">
				<div class="eh-label">Tidsrom</div>
				<div class="eh-field">
					Fra
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="child::*[local-name()='FraDato']"/>
					</xsl:call-template>
					&#160;til&#160;
					<xsl:choose>
						<xsl:when test="child::*[local-name()='TilDato']">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='FraDato']"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>d.d.</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Visning av innhold i Opplysninger til søknad -->
	<xsl:template name="OpplysningerTilSoknad">
		<div class="eh-row-4">
			<div class="eh-col-1">
				<div class="eh-label">Pasientens egensøknad sendt</div>
				<div class="eh-field">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='EgensoknadSendt']='true'">Ja</xsl:when>
						<xsl:otherwise>Nei</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='Merknad']">
				<div class="eh-col-1">
					<div class="eh-label">Merknad</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Info om informasjon som er gitt -->
	<xsl:template name="InfoInformasjonGitt">
		<xsl:for-each select="child::*[local-name()='InformasjonGitt']">		<!--  maxOccurs="unbounded" -->
			<xsl:call-template name="InformasjonGitt"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Info om behov for assistert kommunikasjon mv -->
	<xsl:template name="InfoAssistertKommunikasjon">
		<xsl:param name="stripedCss"/>
		<xsl:for-each select="child::*[local-name()='AssistertKommunikasjon']">	<!-- maxOccurs="1" -->
			<xsl:call-template name="AssistertKommunikasjon">
				<xsl:with-param name="stripedCss" select="$stripedCss" />
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Info om IPLOS-relevant informasjon -->
	<xsl:template name="InfoIPLOSrelevantInformasjon">
		<xsl:for-each select="child::*[local-name()='TidsperiodeDiagnose']">	<!-- maxOccurs="unbounded" -->
			<xsl:call-template name="TidsperiodeDiagnose">
				<xsl:with-param name="stripedCss">
					<xsl:choose>
						<xsl:when test="boolean(position() mod 2)"></xsl:when>
						<xsl:otherwise>striped</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='TidsfestetHendelse']">		<!-- maxOccurs="1" -->
			<xsl:call-template name="TidsfestetHendelse">
				<xsl:with-param name="stripedCss" select="''"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Info om kartlegging av funksjonsnivå -->
	<xsl:template name="InfoKartleggingFunksjonsniva">
		<xsl:for-each select="child::*[local-name()='SamletVurderingFunksjonsniva']">
			<xsl:call-template name="SamletVurderingFunksjonsniva"/>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='Ansvarlig']">
			<xsl:call-template name="Ansvarlig"/>
		</xsl:for-each>
		<xsl:if test="child::*[local-name()='KartlagtFunksjon']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-last-child eh-label">
					Kartlagt funksjon med vurdering
				</div>
			</div>
			<xsl:for-each select="child::*[local-name()='KartlagtFunksjon']">
				<xsl:call-template name="KartlagtFunksjon"/>
			</xsl:for-each>
			<div class="eh-row-4">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label">Koder</div>
					<div class="eh-field">
						1 = ingen problem, 2 = ikke behov for bistand/assistanse, 3 = middels behov for bistand/assistanse, 4 = store behov for bistand/assistanse, 5 = fullt bistandsbehov, 9 = ikke relevant
					</div>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Visning av innhold i Eksisterende tjeneste -->
	<xsl:template name="EksisterendeTjeneste">
		<xsl:param name="stripedCss"/>
		<div class="eh-row-4">
			<div class="eh-col-1 {$stripedCss}">
				<div class="eh-label">
					<xsl:for-each select="child::*[local-name()='IPLOStjenestetype']">
						<xsl:choose>
							<xsl:when test="contains(@S, '9151')"><xsl:call-template name="k-9151"/></xsl:when>
							<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</div>

				<div class="eh-field">
					<xsl:if test="child::*[local-name()='BetegnelseTjeneste'] or child::*[local-name()='TjenestenLevertAv'] or child::*[local-name()='OpplysningerOmTjenesten'] or child::*[local-name()='PrivatTjeneste']">
						<xsl:if test="child::*[local-name()='BetegnelseTjeneste']">
							<div>
								<b>Betegnelse: </b>
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="child::*[local-name()='BetegnelseTjeneste']"/>
								</xsl:call-template>
							</div>
						</xsl:if>
						<xsl:if test="child::*[local-name()='OpplysningerOmTjenesten']">
							<div>
								<b>Opplysninger: </b>
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="child::*[local-name()='OpplysningerOmTjenesten']"/>
								</xsl:call-template>
							</div>
						</xsl:if>
						<xsl:if test="child::*[local-name()='TjenestenLevertAv']">
							<div>
								<b>Levert av: </b>
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="child::*[local-name()='TjenestenLevertAv']"/>
								</xsl:call-template>
							</div>
						</xsl:if>
						<xsl:if test="child::*[local-name()='PrivatTjeneste']">
							<xsl:if test="child::*[local-name()='PrivatTjeneste']='true'">
								<div>Privat&#160;tjeneste</div>
							</xsl:if>
						</xsl:if>
					</xsl:if>&#160;
				</div>
			</div>
			<xsl:if test="child::*[local-name()='AntallEnheter']">
				<div class="eh-col-1 {$stripedCss}">
					<div class="eh-label">Antall</div>
					<div class="eh-field">
						<xsl:value-of select="child::*[local-name()='AntallEnheter']"/>&#160;<xsl:value-of select="child::*[local-name()='Enhet']"/>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Startdato']">
				<div class="eh-col-1 {$stripedCss}">
					<div class="eh-label">Tidsrom</div>
					<div class="eh-field">
						Fra&#160;
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="child::*[local-name()='Startdato']"/>
						</xsl:call-template>
						&#160;til&#160;
						<xsl:choose>
							<xsl:when test="child::*[local-name()='Sluttdato']">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='Sluttdato']"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>d.d.</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Merknad']">
				<div class="eh-col-1 eh-last-child {$stripedCss}">
					<div class="eh-label">Merknad</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Tidsfestet hendelse -->
	<xsl:template name="TidsfestetHendelse">
		<xsl:param name="stripedCss"/>
		<xsl:if test="child::*[local-name()='Hendelsekode']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-label eh-last-child {$stripedCss}">
					<xsl:for-each select="child::*[local-name()='Hendelsekode']">
						<xsl:choose>
							<xsl:when test="contains(@S, '9121')">
								<xsl:choose>
									<xsl:when test="@V='13'">
										<div class="viktig">
											<xsl:call-template name="k-9121"/>
										</div>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="k-9121"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
		<div class="eh-row-4">
			<xsl:if test="child::*[local-name()='TidspunktForHendelse']">
				<div class="eh-col-1 {$stripedCss}">
					<div class="eh-label">Tidspunkt</div>
					<div class="eh-field">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="child::*[local-name()='TidspunktForHendelse']/@V"/>
						</xsl:call-template>&#160;
						<xsl:if test="child::*[local-name()='Anslag']='true'">(anslagsvis)</xsl:if>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='StedForHendelse']">
				<div class="eh-col-1 {$stripedCss}">
					<div class="eh-label">Sted</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='StedForHendelse']/child::*[local-name()='StedHendelse']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='BeskrivelseAvHendelse']">
				<xsl:variable name="lastChildCss">
					<xsl:choose>
						<xsl:when test="not(child::*[local-name()='Merknad'])">eh-last-child</xsl:when>
						<xsl:otherwise></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<div class="eh-col-1 {$lastChildCss} {$stripedCss}">
					<div class="eh-label">Beskrivelse</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='BeskrivelseAvHendelse']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Merknad']">
				<div class="eh-col-1 eh-last-child {$stripedCss}">
					<div class="eh-label">Merknad</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Utskrevet til -->
	<xsl:template name="UtskrevetTil">
		<div class="eh-row-4">
			<div class="eh-col-1">
				<div class="eh-label">Ut til</div>
				<div class="eh-field">
					<xsl:for-each select="child::*[local-name()='UtTil']">
						<xsl:choose>
							<xsl:when test="contains(@S, '8408')"><xsl:call-template name="k-8408"/></xsl:when>
							<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='Uttilstand']">
				<div class="eh-col-1">
					<div class="eh-label">Uttilstand</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='Uttilstand']">
							<xsl:choose>
								<xsl:when test="contains(@S, '8431')">
									<xsl:choose>
										<xsl:when test="@V='2'">
											<div class="viktig">
												<xsl:call-template name="k-8431"/>
											</div>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="k-8431"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Merknad']">
				<div class="eh-col-1">
					<div class="eh-label">>Merknad</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Avtale om adm. av legemidler -->
	<xsl:template name="AvtaleOmAdmLegemidler">
		<div class="eh-row-4">
			<div class="eh-col-1">
				<div class="eh-label">Avtale om adm. av legemidler</div>
				<div class="eh-field">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='AvtaleAdmLegemidler']='true'">Ja</xsl:when>
						<xsl:otherwise>Nei</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
			<div class="eh-col-1">
				<div class="eh-label">Avtale om adm. av multidose:</div>
				<div class="eh-field">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='AvtaleAdmMultidose']='true'">Ja</xsl:when>
						<xsl:otherwise>Nei</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='AdmInstrukser']">
				<div class="eh-col-1">
					<div class="eh-label">Adm. instrukser</div>
					<div class="eh-field">
						<div>
							<xsl:for-each select="child::*[local-name()='AdmInstrukser']/child::*[local-name()='Utleveringsform']">
								<xsl:call-template name="k-9135"/>
							</xsl:for-each>
						</div>
						<div>
							<xsl:for-each select="child::*[local-name()='AdmInstrukser']/child::*[local-name()='SarskilteTiltak']">
								<xsl:call-template name="k-9136"/>
							</xsl:for-each>
						</div>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Merknad']">
				<div class="eh-col-1">
					<div class="eh-label">Merknad</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
		<xsl:for-each select="child::*[local-name()='Tiltaksbeskrivelse']">
			<xsl:call-template name="Tiltaksbeskrivelse"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Medisinskfaglige opplysninger -->
	<xsl:template name="MedisinskfagligeOpplysninger">
		<xsl:for-each select="child::*[local-name()='Cave']">
			<xsl:call-template name="Cave"/>
		</xsl:for-each>

		<xsl:for-each select="child::*[local-name()='Allerginotat']">	<!-- maxOccurs="unbounded" -->
			<xsl:call-template name="Allerginotat">
				<xsl:with-param name="stripedCss">
					<xsl:choose>
						<xsl:when test="boolean(count(child::*[local-name()='Cave']/child::*[local-name()='Allerginotat']) mod 2)">striped</xsl:when>
						<xsl:otherwise></xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:if test="child::*[local-name()='Allerginotat'] | child::*[local-name()='Cave']/child::*[local-name()='Allerginotat']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-last-child horRuler"><hr /></div>
			</div>
		</xsl:if>

		<xsl:for-each select="child::*[local-name()='InfoTidligereSykdommer']">
			<xsl:call-template name="InfoTidligereSykdommer">
				<xsl:with-param name="stripedCss">
					<xsl:choose>
						<xsl:when test="boolean(position() mod 2)"></xsl:when>
						<xsl:otherwise>striped</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:if test="child::*[local-name()='InfoTidligereSykdommer']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-last-child horRuler"><hr /></div>
			</div>
		</xsl:if>

		<xsl:for-each select="child::*[local-name()='GenereltJournalnotat']">
			<xsl:call-template name="GenereltJournalnotat">
				<xsl:with-param name="stripedCss">
					<xsl:choose>
						<xsl:when test="boolean(position() mod 2)"></xsl:when>
						<xsl:otherwise>striped</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:if test="child::*[local-name()='GenereltJournalnotat']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-last-child horRuler"><hr /></div>
			</div>
		</xsl:if>

		<xsl:for-each select="child::*[local-name()='RegistrertBlodtype']">
			<xsl:call-template name="RegistrertBlodtype"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Sykepleierdokumentasjon -->
	<xsl:template name="Sykepleierdokumentasjon">
		<xsl:for-each select="child::*[local-name()='InfoFraSykepleier']">
			<xsl:call-template name="InfoFraSykepleier"/>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='InfoAvtaleOmLegemiddeladm']">
			<xsl:call-template name="InfoAvtaleOmLegemiddeladm"/>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='InfoVurderinger']">	<!-- maxOccurs="unbounded" -->
			<xsl:call-template name="InfoVurderinger"/>
		</xsl:for-each>

		<xsl:for-each select="child::*[local-name()='IverksatteTiltak']">
			<xsl:call-template name="IverksatteTiltak"/>
		</xsl:for-each>
		<xsl:if test="child::*[local-name()='IverksatteTiltak']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-last-child horRuler"><hr /></div>
			</div>
		</xsl:if>

		<xsl:for-each select="child::*[local-name()='AnbefaltVidereTiltak']">
			<xsl:call-template name="AnbefaltVidereTiltak"/>
		</xsl:for-each>
		<xsl:if test="child::*[local-name()='AnbefaltVidereTiltak']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-last-child horRuler"><hr /></div>
			</div>
		</xsl:if>

		<xsl:for-each select="child::*[local-name()='InfoMaalForventetRes']">
			<xsl:call-template name="InfoMaalForventetRes"/>	<!-- maxOccurs="unbounded" -->
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='Ansvarlig']">
			<xsl:call-template name="Ansvarlig"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Info om medisinsk diagnose -->
	<xsl:template name="InfoMedisinskDiagnose">
		<xsl:for-each select="child::*[local-name()='MedisinskDiagnose']">	<!-- her : maxOccurs="unbounded" -->
			<xsl:call-template name="MedisinskDiagnose">
				<xsl:with-param name="stripedCss">
					<xsl:choose>
						<xsl:when test="boolean(position() mod 2)"></xsl:when>
						<xsl:otherwise>striped</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Info om kontaktepisode -->
	<xsl:template name="InfoKontaktepisode">
		<tr>
			<xsl:for-each select="child::*[local-name()='FellesinfoKontaktepisode']">
				<th>
					<xsl:for-each select="child::*[local-name()='Kontakttype']">
						<xsl:choose>
							<xsl:when test="contains(@S, '8432')"><xsl:call-template name="k-8432"/></xsl:when>
							<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
						</xsl:choose>&#160;
					</xsl:for-each>
				</th>
				<xsl:if test="child::*[local-name()='Konsultasjonsform']">
					<td>
						<b>Konsultasjonsform:</b>&#160;
						<xsl:for-each select="child::*[local-name()='Konsultasjonsform']">
							<xsl:call-template name="k-dummy"/>&#160;
						</xsl:for-each>
					</td>
				</xsl:if>
				<th>Startet</th>
				<td width="{((($std-col)-3-count(child::*[local-name()='Konsultasjonsform']))*number(not(child::*[local-name()='Merknad'] | ../child::*[local-name()='TilleggsinfoKontaktepisode']))+1)*$std-td}px" colspan="{(($std-col)-3-count(child::*[local-name()='Konsultasjonsform']))*number(not(child::*[local-name()='Merknad'] | ../child::*[local-name()='TilleggsinfoKontaktepisode']))+1}">
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="child::*[local-name()='KontaktStartet']/@V"/>
					</xsl:call-template>&#160;
					<xsl:if test="child::*[local-name()='KontaktAvsluttet']">
						Avsluttet:&#160;
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="child::*[local-name()='KontaktAvsluttet']/@V"/>
						</xsl:call-template>&#160;
					</xsl:if>
				</td>
				<xsl:if test="child::*[local-name()='Merknad']">
					<th>Merknad</th>
					<td width="{((($std-col)-5-count(child::*[local-name()='Konsultasjonsform']))*number(not(child::*[local-name()='Merknad'] | ../child::*[local-name()='TilleggsinfoKontaktepisode']))+1)*$std-td}px" colspan="{(($std-col)-5-count(child::*[local-name()='Konsultasjonsform']))*number(not(child::*[local-name()='Merknad'] | ../child::*[local-name()='TilleggsinfoKontaktepisode']))+1}">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</td>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="child::*[local-name()='TilleggsinfoKontaktepisode']">
				<th>Sted</th>
				<td width="{(($std-col)-4-count(../child::*[local-name()='FellesinfoKontaktepisode']/child::*[local-name()='Konsultasjonsform'])-count(../child::*[local-name()='FellesinfoKontaktepisode']/child::*[local-name()='Merknad'])*2)*$std-td}px" colspan="{($std-col)-4-count(../child::*[local-name()='FellesinfoKontaktepisode']/child::*[local-name()='Konsultasjonsform'])-count(../child::*[local-name()='FellesinfoKontaktepisode']/child::*[local-name()='Merknad'])*2}">
					<xsl:if test="child::*[local-name()='StedForKontaktepisode']">
						<div>
							<xsl:for-each select="child::*[local-name()='StedForKontaktepisode']">
								<xsl:choose>
									<xsl:when test="contains(@S, '8434')"><xsl:call-template name="k-8434"/></xsl:when>
									<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
								</xsl:choose>&#160;
							</xsl:for-each>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='StedForKontakt']">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='StedForKontakt']"/>
						</xsl:call-template>
					</xsl:if>
				</td>
			</xsl:for-each>
		</tr>
	</xsl:template>

	<!-- Visning av innhold i Info om kontaktepisode -->
	<xsl:template name="InfoReservasjon">
		<xsl:for-each select="child::*[local-name()='ReservasjonOnske']"> 	<!--  maxOccurs="unbounded" -->
			<xsl:call-template name="ReservasjonOnske">
				<xsl:with-param name="stripedCss">
					<xsl:choose>
						<xsl:when test="boolean(position() mod 2)"></xsl:when>
						<xsl:otherwise>striped</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Info om andre viktige opplysninger -->
	<xsl:template name="InfoAndreViktigeOpplysninger">
		<xsl:for-each select="child::*[local-name()='GenereltJournalnotat']">
			<xsl:call-template name="GenereltJournalnotat">
				<xsl:with-param name="stripedCss">
					<xsl:choose>
						<xsl:when test="boolean(position() mod 2)"></xsl:when>
						<xsl:otherwise>striped</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='Allerginotat']">
			<xsl:call-template name="Allerginotat"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Opplysninger fra andre faggrupper -->
	<xsl:template name="OpplysningerAndreFaggrupper">
		<xsl:for-each select="child::*[local-name()='AndreFagrapporter']">
			<xsl:call-template name="AndreFagrapporter"/>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='AnbefaltVidereTiltak']">
			<xsl:call-template name="AnbefaltVidereTiltak"/>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='InfoVurderinger']">	<!-- maxOccurs="unbounded" -->
			<xsl:call-template name="InfoVurderinger"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Opplysninger om opphold -->
	<xsl:template name="OpplysningOpphold">
		<xsl:param name="stripedCss"/>
		<xsl:for-each select="child::*[local-name()='TidsfestetHendelse']">	<!-- maxOccurs="1" -->
			<xsl:call-template name="TidsfestetHendelse">
				<xsl:with-param name="stripedCss" select="$stripedCss" />
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Info om kontrolltime -->
	<xsl:template name="InfoKontrolltime">
		<xsl:for-each select="child::*[local-name()='InformasjonOmTime']">	<!-- maxOccurs="1" -->
			<xsl:call-template name="InformasjonOmTime"/>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='KontrolltimeBestill']">	<!-- maxOccurs="1" -->
			<xsl:call-template name="KontrolltimeBestill"/>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='InformasjonOmTentativTime']">	<!-- maxOccurs="1" -->
			<xsl:call-template name="InformasjonOmTentativTime"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Opplysninger om hjelpemidler -->
	<xsl:template name="OpplysningerOmHjelpemidler">
		<xsl:for-each select="child::*[local-name()='FasteHjelpemidler']">	<!-- maxOccurs="unbounded" -->
			<xsl:call-template name="FasteHjelpemidler"/>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='StatusHjelpemiddel']">	<!-- maxOccurs="unbounded" -->
			<xsl:call-template name="StatusHjelpemiddel"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Behov for tjeneste -->
	<xsl:template name="TjenesteBehov">
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label eh-last-child">
				<xsl:for-each select="child::*[local-name()='IPLOStjenestetype']">
					<xsl:choose>
						<xsl:when test="contains(@S, '9151')"><xsl:call-template name="k-9151"/></xsl:when>
						<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
					</xsl:choose>&#160;
				</xsl:for-each>
				<xsl:if test="not(child::*[local-name()='IPLOStjenestetype']) and child::*[local-name()='BetegnelseTjeneste']">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="child::*[local-name()='BetegnelseTjeneste']"/>
					</xsl:call-template>
				</xsl:if>
			</div>
		</div>
		<div class="eh-row-4">
			<xsl:if test="child::*[local-name()='VedInstitusjon']">
				<div class="eh-col-1">
					<div class="eh-label">Ønsket institusjon</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='VedInstitusjon']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='BeskrivelseAvTjeneste']">
				<div class="eh-col-2">
					<div class="eh-label">Beskrivelse</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='BeskrivelseAvTjeneste']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='AntallEnheterOnsket']">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label">Ønsket antall</div>
					<div class="eh-field">
						<xsl:value-of select="child::*[local-name()='AntallEnheterOnsket']"/>&#160;<xsl:value-of select="child::*[local-name()='Enhet']"/>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Assistert kommunikasjon -->
	<xsl:template name="AssistertKommunikasjon">
		<xsl:param name="stripedCss"/>
		<div class="eh-row-4">
			<xsl:if test="child::*[local-name()='PersonTolkebehov']">
				<div class="eh-col-1 $stripedCss">
					<div class="eh-label">Gjelder for</div>
					<div class="eh-field inline-content">
						<xsl:for-each select="child::*[local-name()='PersonTolkebehov']">
							<xsl:call-template name="Person"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='BehovTolkSprak']">
				<div class="eh-col-1 $stripedCss">
					<div class="eh-label">Behov for tolk - Språk</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='BehovTolkSprak']">
							<xsl:call-template name="k-3303"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='PreferertTolk']">
				<div class="eh-col-1 $stripedCss">
					<div class="eh-label">Ønsket tolk</div>
					<div class="eh-field inline-content">
						<xsl:for-each select="child::*[local-name()='PreferertTolk']">
							<xsl:call-template name="Person"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Horselsvikt'] or child::*[local-name()='Synsvikt'] or child::*[local-name()='BehovOpphortDato'] or child::*[local-name()='Merknad']">
				<div class="eh-col-1 $stripedCss">
					<div class="eh-label">Merknad</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
						<xsl:if test="child::*[local-name()='Horselsvikt']='true' or child::*[local-name()='Synsvikt']='true' or child::*[local-name()='BehovOpphortDato']">
							<xsl:if test="child::*[local-name()='Horselsvikt']='true'">
								<xsl:if test="child::*[local-name()='Merknad']">
									<br />
								</xsl:if>
								<b>Hørselsvikt:</b>&#160;Ja&#160;
							</xsl:if>
							<xsl:if test="child::*[local-name()='Synsvikt']='true'">
								<xsl:if test="child::*[local-name()='Merknad'] or child::*[local-name()='Horselsvikt']">
									<br />
								</xsl:if>
								<b>Synsvikt:</b>&#160;Ja&#160;
							</xsl:if>
							<xsl:if test="child::*[local-name()='BehovOpphortDato']/@V">
								<xsl:if test="child::*[local-name()='Merknad'] or child::*[local-name()='Horselsvikt'] or child::*[local-name()='Synsvikt']">
									<br />
								</xsl:if>
								<b>Behov&#160;opphørte:</b>&#160;
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='BehovOpphortDato']/@V"/>
								</xsl:call-template>&#160;
							</xsl:if>
						</xsl:if>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Registrert blodtype -->
	<xsl:template name="RegistrertBlodtype">
		<div class="eh-row-4">
			<div class="eh-col-1">
				<div class="eh-label">Registrert&#160;blodtype</div>
				<div class="eh-field">
					<xsl:for-each select="child::*[local-name()='Blodtype']"><xsl:value-of select="@V"/></xsl:for-each>
					<xsl:for-each select="child::*[local-name()='Rhesusgruppe']">,&#160;<xsl:value-of select="@V"/></xsl:for-each>
				</div>
				<xsl:if test="child::*[local-name()='Merknad']">
					<div class="eh-label">Merknad</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</xsl:if>
			</div>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Andre fagrapporter -->
	<xsl:template name="AndreFagrapporter">
		<xsl:variable name="kol" select="number(boolean(child::*[local-name()='BehandlingStart'] | child::*[local-name()='StatusInnleggelse'] | child::*[local-name()='StatusBehandlingsstart'] | child::*[local-name()='ForventetStatusUtskriving']))+count(child::*[local-name()='AnsvarligRapport'])*2+1"/>
		<xsl:variable name="rad" select="count(.//child::*[local-name()='Journaltekst'])"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label eh-last-child">Fagrapport</div>
		</div>
		<div class="eh-row-4">
			<xsl:if test="child::*[local-name()='BehandlingStart'] or child::*[local-name()='StatusInnleggelse'] or child::*[local-name()='StatusBehandlingsstart'] or child::*[local-name()='ForventetStatusUtskriving']">
				<div class="eh-col-1">
					<xsl:if test="child::*[local-name()='BehandlingStart']">
						<div class="eh-label">Behandlingstart</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='BehandlingStart']"/>
							</xsl:call-template>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='StatusInnleggelse']">
						<div class="eh-label">Status innleggelse:</div>
						<div class="eh-field">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='StatusInnleggelse']"/>
							</xsl:call-template>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='StatusBehandlingsstart']">
						<div class="eh-label">Status behandlingsstart:</div>
						<div class="eh-field">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='StatusBehandlingsstart']"/>
							</xsl:call-template>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='ForventetStatusUtskriving']">
						<div class="eh-label">Forventet&#160;status&#160;utskriving:</div>
						<div class="eh-field">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='ForventetStatusUtskriving']"/>
							</xsl:call-template>
						</div>
					</xsl:if>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='AnsvarligRapport']">
				<div class="eh-col-1">
					<div class="eh-label">Ansvarlig</div>
					<div class="eh-field inline-content">
						<xsl:for-each select="child::*[local-name()='AnsvarligRapport']">
							<xsl:call-template name="HealthcareProfessional"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:for-each select="child::*[local-name()='Journaltekst']">
				<xsl:if test="position()=1">
					<xsl:call-template name="Journaltekst"><xsl:with-param name="inline" select="true()"/></xsl:call-template>
				</xsl:if>
			</xsl:for-each>
		</div>
		<xsl:for-each select="child::*[local-name()='Journaltekst']">
			<xsl:if test="position()!=1">
				<xsl:call-template name="Journaltekst"><xsl:with-param name="inline" select="false()"/></xsl:call-template>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Info om tidligere sykdommer -->
	<xsl:template name="InfoTidligereSykdommer">
		<xsl:param name="stripedCss"/>
		<xsl:variable name="rad" select="1+count(child::*[local-name()='Journaltekst'])"/>
		<div class="eh-row-4">
			<div class="eh-col-1 {$stripedCss}">
				<div class="eh-label">Tidligere sykdom</div>
				<div class="eh-field">
					<xsl:for-each select="child::*[local-name()='TidligereSykdomFragment']/child::*[local-name()='Diagnosekode']">
						&#160;<xsl:value-of select="@V"/>&#160;
						<xsl:if test="contains(@S, '7170')">(ICPC)</xsl:if>
						<xsl:if test="contains(@S, '7110')">(ICD-10)</xsl:if>
					</xsl:for-each>
				</div>
			</div>
			<xsl:for-each select="child::*[local-name()='TidligereSykdomFragment']">
				<xsl:if test="child::*[local-name()='Diagnosekode']">
					<div class="eh-col-1 {$stripedCss}">
						<div class="eh-label">Diagnose</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='Diagnosekode']">
								<xsl:call-template name="k-dummy"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='FunksjonshemmingKroniskSykdom']='true'">
					<div class="eh-col-1 {$stripedCss}">
						<div class="eh-label">Gjelder</div>
						<div class="eh-field">
							<xsl:if test="child::*[local-name()='FunksjonshemmingKroniskSykdom']='true'">Gjelder funksjonshemming/kronisk sykdom</xsl:if>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='TidligereSykdom']">
					<div class="eh-col-1 {$stripedCss}">
						<div class="eh-label">Stikkord/beskrivelse</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='TidligereSykdom']">
								<xsl:if test="position()!=1">,&#160;</xsl:if>
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="."/>
								</xsl:call-template>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</xsl:for-each>
		</div>
		<xsl:for-each select="child::*[local-name()='Journaltekst']">
			<div class="eh-row-4">
				<xsl:call-template name="Journaltekst"><xsl:with-param name="inline" select="false()"/></xsl:call-template>
			</div>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Info fra sykepleier -->
	<xsl:template name="InfoFraSykepleier">
		<div class="eh-row-4">
			<xsl:for-each select="child::*[local-name()='OpplysningerRelevantOppfolging']">
				<xsl:if test="child::*[local-name()='EndringFunksjonsnivaa']">
					<div class="eh-col-1">
						<div class="eh-label">Endring i funksjonsnivå</div>
						<div class="eh-field">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='EndringFunksjonsnivaa']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='BandasjemateriellEngangsutstyr']">
					<div class="eh-col-1">
						<div class="eh-label">Sendt med?</div>
						<div class="eh-field">
							Bandasjemateriell og engangsutstyr er <xsl:if test="child::*[local-name()='BandasjemateriellEngangsutstyr']='false'">ikke </xsl:if>sendt med pasienten
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='MerknadTilBandasjemateriell']">
					<div class="eh-col-1">
						<div class="eh-field">
							<div class="eh-label">Merknad:</div>
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='MerknadTilBandasjemateriell']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='HjelpLegemiddeladm']">
					<div class="eh-col-1">
						<div class="eh-label">Trenger hjelp?</div>
						<div class="eh-field">
							Pasienten trenger <xsl:if test="child::*[local-name()='HjelpLegemiddeladm']='false'">ikke </xsl:if>hjelp til legemiddeladministrering
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='MerknadTilLegemiddeladministrering']">
					<div class="eh-col-1">
						<div class="eh-field">
							<b>Merknad:</b>&#160;
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='MerknadTilLegemiddeladministrering']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
			</xsl:for-each>
		</div>
		<xsl:for-each select=".//child::*[local-name()='Journaltekst']">
			<div class="eh-row-4">
				<xsl:call-template name="Journaltekst"><xsl:with-param name="inline" select="false()"/></xsl:call-template>
			</div>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Informasjon om bestilt time -->
	<xsl:template name="InformasjonOmTime">
		<div class="eh-row-4">
			<div class="eh-col-1">
				<div class="eh-label">Informasjon om bestilt time</div>
				<div class="eh-field">
					Bestilt:&#160;
					<xsl:choose>
						<xsl:when test="child::*[local-name()='BestiltKontrolltime']='true'">Ja</xsl:when>
						<xsl:otherwise>Nei</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='StedTime']">
				<div class="eh-col-1">
					<div class="eh-label">Sted</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='StedTime']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='TidspunktTime'] or child::*[local-name()='Varighet']">
				<div class="eh-col-1">
					<div class="eh-label">
						<xsl:if test="child::*[local-name()='TidspunktTime']">Tidspunkt</xsl:if>
						<xsl:if test="child::*[local-name()='TidspunktTime'] and child::*[local-name()='Varighet']"> og varighet</xsl:if>
						<xsl:if test="not(child::*[local-name()='TidspunktTime']) and child::*[local-name()='Varighet']">Varighet</xsl:if>
					</div>
					<div class="eh-field">
						<xsl:if test="child::*[local-name()='TidspunktTime']">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='TidspunktTime']"/>
							</xsl:call-template>&#160;
						</xsl:if>
						<xsl:if test="child::*[local-name()='Varighet']">
							<xsl:value-of select="child::*[local-name()='Varighet']"/>minutter
						</xsl:if>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='InformertOm']">
				<div class="eh-col-1">
					<div class="eh-label">Informert</div>
					<div class="eh-field">
						<div>Pasient:
							<xsl:choose>
								<xsl:when test="child::*[local-name()='InformertOm']/child::*[local-name()='PasientInformert']='true'">Ja</xsl:when>
								<xsl:otherwise>Nei</xsl:otherwise>
							</xsl:choose>
						</div>
						<div>Pårørende:
							<xsl:choose>
								<xsl:when test="child::*[local-name()='InformertOm']/child::*[local-name()='ParorendeInformert']='true'">Ja</xsl:when>
								<xsl:otherwise>Nei</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Kontrolltime skal bestilles -->
	<xsl:template name="KontrolltimeBestill">
		<div class="eh-row-4">
			<div class="eh-col-1">
				<div class="eh-label">Kontrolltime skal bestilles</div>
				<div class="eh-field">
					Bestilles av pasient/pårørende:
					<xsl:choose>
						<xsl:when test="child::*[local-name()='PasientParorendeBestiller']='true'">Ja</xsl:when>
						<xsl:otherwise>Nei</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='InformertOm']">
				<div class="eh-col-1">
				<div class="eh-label">Informert</div>
				<div class="eh-field">
					Pasient:&#160;
					<xsl:choose>
						<xsl:when test="child::*[local-name()='InformertOm']/child::*[local-name()='PasientInformert']='true'">Ja</xsl:when>
						<xsl:otherwise>Nei</xsl:otherwise>
					</xsl:choose>
					<br />
					Pårørende:&#160;
					<xsl:choose>
						<xsl:when test="child::*[local-name()='InformertOm']/child::*[local-name()='ParorendeInformert']='true'">Ja</xsl:when>
						<xsl:otherwise>Nei</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Informasjon om tentativ kontrolltime -->
	<xsl:template name="InformasjonOmTentativTime">
		<div class="eh-row-4">
			<div class="eh-col-1">
				<div class="eh-label">Informasjon om tentativ kontrolltime</div>
				<div class="eh-field">
					<xsl:if test="po.TentativtTidspunktTime">
						Tentativt tidspunkt:
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='TentativtTidspunktTime']"/>
						</xsl:call-template>
					</xsl:if>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='StedTime']">
				<div class="eh-col-1">
					<div class="eh-label">Sted</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='StedTime']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Merknad']">
				<div class="eh-col-1">
					<div class="eh-label">Merknad</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='InformertOm']">
				<div class="eh-col-1">
					<div class="eh-label">Informert</div>
					<div class="eh-field">
						Pasient:&#160;
						<xsl:choose>
							<xsl:when test="child::*[local-name()='InformertOm']/child::*[local-name()='PasientInformert']='true'">Ja</xsl:when>
							<xsl:otherwise>Nei</xsl:otherwise>
						</xsl:choose>
						<br />
						Pårørende:&#160;
						<xsl:choose>
							<xsl:when test="child::*[local-name()='InformertOm']/child::*[local-name()='ParorendeInformert']='true'">Ja</xsl:when>
							<xsl:otherwise>Nei</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Kartlagt funksjon -->
	<xsl:template name="KartlagtFunksjon">
		<div class="eh-row-4">
			<div class="eh-col-1 eh-field">
				<xsl:if test="child::*[local-name()='Vurdering']"><xsl:value-of select="child::*[local-name()='Vurdering']"/>&#160;-&#160;</xsl:if>
				<xsl:if test="child::*[local-name()='Funksjonsvariabel']">
					<xsl:for-each select="child::*[local-name()='Funksjonsvariabel']">
						<xsl:choose>
							<xsl:when test="contains(@S, '9111')"><xsl:call-template name="k-9111"/></xsl:when>
							<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
						</xsl:choose>&#160;
					</xsl:for-each>
				</xsl:if>
			</div>
			<xsl:if test="child::*[local-name()='Merknad']">
				<div class="eh-col-1 eh-field">
					<b>Merknad:</b>&#160;
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
					</xsl:call-template>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Informasjon gitt -->
	<xsl:template name="InformasjonGitt">
		<div class="eh-row-4">
			<xsl:if test="child::*[local-name()='TypeInformasjon'] or child::*[local-name()='BeskrivelseInformasjon']">
				<div class="eh-col-1">
					<div class="eh-label">
						<xsl:if test="child::*[local-name()='TypeInformasjon']">
							<xsl:for-each select="child::*[local-name()='TypeInformasjon']">
								<xsl:choose>
									<xsl:when test="contains(@S, '9502')"><xsl:call-template name="k-9502"/></xsl:when>
									<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</xsl:if>&#160;
					</div>
					<div class="eh-field">
						<xsl:if test="child::*[local-name()='BeskrivelseInformasjon']">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='BeskrivelseInformasjon']"/>
							</xsl:call-template>
						</xsl:if>&#160;
					</div>
				</div>
			</xsl:if>
			<div class="eh-col-1">
				<div class="eh-label">Gitt til</div>
				<div class="eh-field inline-content">
					<xsl:for-each select="child::*[local-name()='InformasjonGittTil']">
						<xsl:call-template name="Person"/>
					</xsl:for-each>
					<br/>
					<xsl:choose>
						<xsl:when test="child::*[local-name()='MuntligInformasjon']='true'">
							<div>Gitt&#160;muntlig:&#160;Ja</div>
						</xsl:when>
						<xsl:when test="child::*[local-name()='MuntligInformasjon']='false'">
							<div>Gitt&#160;muntlig:&#160;Nei</div>
						</xsl:when>
					</xsl:choose>
				</div>
			</div>
			<div class="eh-col-1">
				<div class="eh-label">Gitt av</div>
				<div class="eh-field inline-content">
					<xsl:for-each select="child::*[local-name()='InformasjonGittAv']">
						<xsl:call-template name="HealthcareProfessional"/>
					</xsl:for-each>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='InformasjonGittDato']">
				<div class="eh-col-1">
					<div class="eh-label">Gitt dato</div>
					<div class="eh-field">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="child::*[local-name()='InformasjonGittDato']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Info om avtale om legemiddeladministrering -->
	<xsl:template name="InfoAvtaleOmLegemiddeladm">
		<xsl:for-each select="child::*[local-name()='AvtaleOmAdmLegemidler']">
			<xsl:call-template name="AvtaleOmAdmLegemidler"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Ansvarlig -->
	<xsl:template name="Ansvarlig">
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label eh-last-child">
				Ansvar
				<xsl:for-each select="child::*[local-name()='TypeHendelse']">
					:&#160;<xsl:choose>
						<xsl:when test="contains(@S, '9131')"><xsl:call-template name="k-9131"/></xsl:when>
						<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
					</xsl:choose>&#160;
				</xsl:for-each>
			</div>
		</div>
		<div class="eh-row-4">
			<xsl:if test="child::*[local-name()='AnsvarligTjenesteyter']">
				<div class="eh-col-1">
					<div class="eh-label">Ansvarlig tjenesteyter</div>
					<div class="eh-field inline-content">
						<xsl:for-each select="child::*[local-name()='AnsvarligTjenesteyter']">
							<xsl:call-template name="HealthcareProfessional"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Virksomhet']">
				<div class="eh-col-1">
					<div class="eh-label">Virksomhet</div>
					<div class="eh-field inline-content">
						<xsl:for-each select="child::*[local-name()='Virksomhet']">
							<xsl:call-template name="Organisation"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<div class="eh-col-1">
				<div class="eh-label">Tidspunkt</div>
				<div class="eh-field">
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="child::*[local-name()='TidspunktForHendelse']"/>
					</xsl:call-template>
					<xsl:if test="child::*[local-name()='Ekstern']='true'">
						<div>Vurderingen er foretatt av helsepersonell utenfor journalførende virksomheten.</div>
					</xsl:if>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='Merknad']">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label">Merknad</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Anbefalt videre tiltak -->
	<xsl:template name="AnbefaltVidereTiltak">
		<xsl:for-each select="child::*[local-name()='Tiltaksbeskrivelse']">
			<xsl:call-template name="Tiltaksbeskrivelse"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Reservasjon/ønske -->
	<xsl:template name="ReservasjonOnske">
		<xsl:param name="stripedCss" />
		<div class="eh-row-5">
			<div class="eh-col-2 {$stripedCss}">
				<div class="eh-label">Gjelder</div>
				<div class="eh-field">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="child::*[local-name()='Gjelder']"/>
					</xsl:call-template>
				</div>
			</div>
			<div class="eh-col-1 {$stripedCss}">
				<div class="eh-label">Framsatt av</div>
				<div class="eh-field inline-content">
					<xsl:for-each select="child::*[local-name()='FramsattAv']">
						<xsl:call-template name="Person"/>
					</xsl:for-each>
					<b>Framsatt:&#160;</b>
					<xsl:call-template name="skrivUtTS">
						<xsl:with-param name="oppgittTid" select="child::*[local-name()='FramsattDato']"/>
					</xsl:call-template>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='TrukketTilbakeAv'] or child::*[local-name()='TrukketTilbakeDato']">
				<div class="eh-col-1 {$stripedCss}">
					<div class="eh-label">Trukket tilbake <xsl:if test="child::*[local-name()='TrukketTilbakeAv']">av</xsl:if></div>
					<div class="eh-field inline-content">
						<xsl:if test="child::*[local-name()='TrukketTilbakeAv']">
							<xsl:for-each select="child::*[local-name()='TrukketTilbakeAv']">
								<xsl:call-template name="Person"/>
							</xsl:for-each>
						</xsl:if>
						<xsl:if test="child::*[local-name()='TrukketTilbakeDato']"><b>Trukket tilbake: </b></xsl:if>
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="child::*[local-name()='TrukketTilbakeDato']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Merknad']">
				<div class="eh-col-1 {$stripedCss} eh-last-child">
					<div class="eh-label">Merknad</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Faste hjelpemidler -->
	<xsl:template name="FasteHjelpemidler">
		<div class="eh-row-4">
			<xsl:if test="child::*[local-name()='Briller']">
				<div class="eh-col-1">
					<div class="eh-label">Briller</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='Briller']">
							<xsl:call-template name="k-9113"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='HjelpemiddelHorsel']">
				<div class="eh-col-1">
					<div class="eh-label">Hjelpemiddel hørsel</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='HjelpemiddelHorsel']">
							<xsl:call-template name="k-9114"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Pacemaker']">
				<div class="eh-col-1">
					<div class="eh-label">Pacemaker</div>
					<div class="eh-field">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='Pacemaker']='true'">Ja</xsl:when>
							<xsl:otherwise>Nei</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Merknad']">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label">Merknad</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Faste hjelpemidler -->
	<xsl:template name="SamletVurderingFunksjonsniva">
		<div class="eh-row-4">
			<div class="eh-col-1">
				<div class="eh-label">Samlet vurdering</div>
				<xsl:if test="child::*[local-name()='Merknad']">
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
						</xsl:call-template>
					</div>
				</xsl:if>
			</div>
			<xsl:if test="child::*[local-name()='Pleietyngde']">
				<div class="eh-col-1">
					<div class="eh-label">Pleietyngde</div>
					<div class="eh-field">
						<xsl:value-of select="child::*[local-name()='Pleietyngde']"/>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='VurderingPleietyngde']">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label">Vurdering pleietyngde</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='VurderingPleietyngde']"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Tidsperiode for diagnosen -->
	<xsl:template name="TidsperiodeDiagnose">
		<xsl:param name="stripedCss"/>
		<!-- Start- og sluttdato for diagnosen vises i MedisinskDiagnose-template -->
		<xsl:for-each select="child::*[local-name()='MedisinskDiagnose']">	<!-- her : maxOccurs="1"  -->
			<xsl:call-template name="MedisinskDiagnose">
				<xsl:with-param name="stripedCss" select="$stripedCss" />
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Info om mål/forventet resultat -->
	<xsl:template name="InfoMaalForventetRes">
		<xsl:variable name="rad" select="count(child::*[local-name()='InnholdMaaldokument'])+count(.//child::*[local-name()='Journaltekst'])"/>

		<div class="eh-row-4">
			<div class="eh-col-1 eh-label eh-last-child">
				Forventet mål
				<xsl:for-each select="child::*[local-name()='InnholdMaaldokument']/child::*[local-name()='MaalForventetResultat']">
					:&#160;<xsl:call-template name="k-dummy"/>&#160;
				</xsl:for-each>
			</div>
		</div>

		<xsl:for-each select="child::*[local-name()='InnholdMaaldokument']">	<!-- maxOccurs="1" -->
			<div class="eh-row-4">
				<xsl:if test="child::*[local-name()='ForventetGradMaaloppnaaelse'] or child::*[local-name()='Beskrivelse'] or child::*[local-name()='ForventesOppnaadd']">
					<xsl:if test="child::*[local-name()='Beskrivelse']">
						<div class="eh-col-1">
							<div class="eh-label">Beskrivelse:</div>
							<div class="eh-field">
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="child::*[local-name()='Beskrivelse']"/>
								</xsl:call-template>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='ForventesOppnaadd']">
						<div class="eh-col-1">
							<div class="eh-label">Forventes&#160;oppnådd:</div>
							<div class="eh-field">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='ForventesOppnaadd']"/>
								</xsl:call-template>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='ForventetGradMaaloppnaaelse']">
						<div class="eh-col-1">
							<div class="eh-label">Forventet&#160;grad</div>
							<div class="eh-field">
								<xsl:for-each select="child::*[local-name()='ForventetGradMaaloppnaaelse']">
									:&#160;<xsl:call-template name="k-dummy"/>&#160;
								</xsl:for-each>
							</div>
						</div>
					</xsl:if>
				</xsl:if>
				<xsl:if test="child::*[local-name()='KategoriHelsepersonell']">
					<div class="eh-col-1">
						<div class="eh-label">Utformet&#160;av</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='KategoriHelsepersonell']">
								<xsl:call-template name="k-9060"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='FraDato'] or child::*[local-name()='TilDato']">
					<div class="eh-col-1">
						<div class="eh-label">Gyldighet</div>
						<div class="eh-field">
							<xsl:if test="child::*[local-name()='FraDato']">
								<div>
									<b>Fra:</b>&#160;
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='FraDato']"/>
									</xsl:call-template>&#160;
								</div>
							</xsl:if>
							<xsl:if test="child::*[local-name()='TilDato']">
								<div>
									<b>Til:</b>&#160;
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='TilDato']"/>
									</xsl:call-template>&#160;
								</div>
							</xsl:if>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Stikkord']">
					<div class="eh-col-1">
						<div class="eh-label">Stikkord</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='Stikkord']">
								<xsl:if test="position()!=1">,&#160;</xsl:if>
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="."/>
								</xsl:call-template>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
		<xsl:for-each select=".//child::*[local-name()='Journaltekst']">	<!-- maxOccurs="unbounded" -->
			<div class="eh-row-4">
				<xsl:call-template name="Journaltekst"><xsl:with-param name="inline" select="false()"/></xsl:call-template>
			</div>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Info om vurderinger -->
	<xsl:template name="InfoVurderinger">
		<xsl:variable name="rad" select="count(child::*[local-name()='InnholdVurdering'])+count(.//child::*[local-name()='Enkeltvurdering'])+count(.//child::*[local-name()='Journaltekst'])"/>

		<div class="eh-row-4">
			<div class="eh-col-1 eh-label eh-last-child">
				Vurdering av:
				<xsl:call-template name="line-breaks">
					<xsl:with-param name="text" select="child::*[local-name()='InnholdVurdering']/child::*[local-name()='VurderingenGjelder']"/>
				</xsl:call-template>
			</div>
		</div>
		<xsl:for-each select="child::*[local-name()='InnholdVurdering']">	<!-- maxOccurs="1" -->
			<xsl:if test="child::*[local-name()='KategoriHelsepersonell'] or child::*[local-name()='FraDato'] or child::*[local-name()='TilDato'] or child::*[local-name()='Stikkord']">
				<div class="eh-row-4">
					<xsl:if test="child::*[local-name()='KategoriHelsepersonell']">
						<div class="eh-col-1">
							<div class="eh-label">Vurdert av</div>
							<div class="eh-field">
								<xsl:for-each select="child::*[local-name()='KategoriHelsepersonell']">
									<xsl:call-template name="k-9060"/>
								</xsl:for-each>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='FraDato'] or child::*[local-name()='TilDato']">
						<div class="eh-col-1">
							<div class="eh-label">Gyldighet</div>
							<div class="eh-field">
								<xsl:if test="child::*[local-name()='FraDato']">
									<div>
										<b>Fra:</b>&#160;
										<xsl:call-template name="skrivUtTS">
											<xsl:with-param name="oppgittTid" select="child::*[local-name()='FraDato']"/>
										</xsl:call-template>&#160;
									</div>
								</xsl:if>
								<xsl:if test="child::*[local-name()='TilDato']">
									<div>
										<b>Til:</b>&#160;
										<xsl:call-template name="skrivUtTS">
											<xsl:with-param name="oppgittTid" select="child::*[local-name()='TilDato']"/>
										</xsl:call-template>&#160;
									</div>
								</xsl:if>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='Stikkord']">
						<div class="eh-col-1">
							<div class="eh-label">Stikkord</div>
							<div class="eh-field">
								<xsl:for-each select="child::*[local-name()='Stikkord']">
									<xsl:if test="position()!=1">,&#160;</xsl:if>
									<xsl:call-template name="line-breaks">
										<xsl:with-param name="text" select="."/>
									</xsl:call-template>
								</xsl:for-each>
							</div>
						</div>
					</xsl:if>
				</div>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select=".//child::*[local-name()='Enkeltvurdering']">	<!-- maxOccurs="unbounded" -->
			<div class="eh-row-4">
				<xsl:if test="child::*[local-name()='VurderingTekst']">
					<div class="eh-col-1">
						<div class="eh-label">Tekstlig vurdering:</div>
						<div class="eh-field">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='VurderingTekst']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Funksjonsområde']">
					<div class="eh-col-1">
						<div class="eh-label">Funksjonsområde</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='Funksjonsområde']">
								<xsl:choose>
									<xsl:when test="contains(@S, '9536')"><xsl:call-template name="k-9536"/></xsl:when>
									<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
								</xsl:choose>&#160;
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='KodetVurdering']">
					<div class="eh-col-1">
						<div class="eh-label">Kodet vurdering</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='KodetVurdering']">
								<xsl:value-of select="@V"/>&#160;
								<xsl:if test="contains(@S, '7150')">(NANDA)</xsl:if>
								<xsl:if test="contains(@S, '7140')">(NOC)</xsl:if>
								<xsl:if test="contains(@S, '7130')">(NIC)</xsl:if>
								<xsl:if test="contains(@S, '7250')">(ICF)</xsl:if>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
		<xsl:for-each select=".//child::*[local-name()='Journaltekst']">	<!-- maxOccurs="unbounded" -->
			<div class="eh-row-4">
				<xsl:call-template name="Journaltekst"><xsl:with-param name="inline" select="false()"/></xsl:call-template>
			</div>
		</xsl:for-each>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-last-child horRuler"><hr /></div>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Iverksatte tiltak -->
	<xsl:template name="IverksatteTiltak">
		<xsl:for-each select="child::*[local-name()='Tiltaksbeskrivelse']">
			<xsl:call-template name="Tiltaksbeskrivelse"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av innhold i Medisinsk diagnose -->
	<xsl:template name="MedisinskDiagnose">
		<xsl:param name="stripedCss" />

		<div class="eh-row-4">
			<xsl:if test="child::*[local-name()='Diagnosekode']">
				<div class="eh-col-1 {$stripedCss}">
					<div class="eh-label">
						<xsl:value-of select="child::*[local-name()='Diagnosekode']/@V"/>&#160;
						<xsl:if test="contains(child::*[local-name()='Diagnosekode']/@S, '7170')">(ICPC)</xsl:if>
						<xsl:if test="contains(child::*[local-name()='Diagnosekode']/@S, '7110')">(ICD-10)</xsl:if>
					</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='Diagnosekode']">
							<xsl:call-template name="k-dummy"/>&#160;
						</xsl:for-each>
						<xsl:if test="child::*[local-name()='Hoveddiagnose']">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='Hoveddiagnose']='true'">(Hoveddiagnose)</xsl:when>
								<xsl:otherwise>(Bidiagnose)</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='DiagnoseBeskrivelse']">
				<div class="eh-col-1 eh-last-child {$stripedCss}">
					<div class="eh-label">Beskrivelse</div>
					<div class="eh-field">
						<xsl:if test="child::*[local-name()='DiagnoseBeskrivelse']">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='DiagnoseBeskrivelse']"/>
							</xsl:call-template>
						</xsl:if>
					</div>
				</div>
			</xsl:if>
		</div>
		<xsl:if test="../child::*[local-name()='StartdatoDiagnose'] | ../child::*[local-name()='SluttdatoDiagnose']">
			<div class="eh-row-4">
				<xsl:if test="../child::*[local-name()='StartdatoDiagnose']">
					<div class="eh-col-1 {$stripedCss}">
						<div class="eh-label">Startdato (Diagn.)</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../child::*[local-name()='StartdatoDiagnose']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="../child::*[local-name()='SluttdatoDiagnose']">
					<div class="eh-col-1 {$stripedCss}">
						<div class="eh-label">Sluttdato (Diagn.)</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../child::*[local-name()='SluttdatoDiagnose']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Visning av innhold i Status til hjelpemiddel -->
	<xsl:template name="StatusHjelpemiddel">
		<div class="eh-row-4">
			<div class="eh-col-1">
				<div class="eh-label">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='Hjelpemiddelbeskrivelse']/child::*[local-name()='HjelpemiddelkodeRTV']">
							<xsl:for-each select="child::*[local-name()='Hjelpemiddelbeskrivelse']/child::*[local-name()='HjelpemiddelkodeRTV']">
								<xsl:call-template name="k-dummy"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Betegnelse</xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="eh-field">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="child::*[local-name()='Hjelpemiddelbeskrivelse']/child::*[local-name()='BetegnelseHjelpemiddel']"/>
					</xsl:call-template>
				</div>
			</div>
			<div class="eh-col-1">
				<div class="eh-label">Status</div>
				<div class="eh-field">
					<xsl:for-each select="child::*[local-name()='Status']">
						<xsl:call-template name="k-8230"/>
					</xsl:for-each>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='Hjelpemiddelbeskrivelse']/child::*[local-name()='Sekvensnummer']">
				<div class="eh-col-1">
					<div class="eh-label">Sekvensnummer</div>
					<div class="eh-field">
						<xsl:value-of select="child::*[local-name()='Hjelpemiddelbeskrivelse']/child::*[local-name()='Sekvensnummer']"/>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av innhold i Tiltaksbeskrivelse -->
	<xsl:template name="Tiltaksbeskrivelse">
		<xsl:variable name="rad" select="1+count(.//child::*[local-name()='GjennomforingAvTiltak'])+count(child::*[local-name()='PlanlagtGjennomforingTiltak'])"/>

		<div class="eh-row-4">
			<div class="eh-col-1">
				<div class="eh-label">
					<xsl:choose>
						<xsl:when test="local-name(..)='IverksatteTiltak'">
							Iverksatte tiltak:
						</xsl:when>
						<xsl:when test="local-name(..)='AnbefaltVidereTiltak'">
							Anbefalte videre tiltak:
						</xsl:when>
						<xsl:when test="local-name(..)='AvtaleOmAdmLegemidler'">
							Tiltak:
						</xsl:when>
					</xsl:choose>
				</div>
				<xsl:if test="child::*[local-name()='IntervensjonTiltakBeskrivelse'] or child::*[local-name()='IntervensjonTiltakKode']">
					<div class="eh-field">
						<xsl:if test="child::*[local-name()='IntervensjonTiltakBeskrivelse']">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='IntervensjonTiltakBeskrivelse']"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:for-each select="child::*[local-name()='IntervensjonTiltakKode']">
							<div>&#160;-&#160;
								<xsl:choose>
									<xsl:when test="contains(@S, '9132')"><xsl:call-template name="k-9132"/></xsl:when>
									<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
								</xsl:choose>
							</div>
						</xsl:for-each>
					</div>
				</xsl:if>
			</div>
			<xsl:if test="child::*[local-name()='KategoriHelsepersonell']">
				<div class="eh-col-1">
					<div class="eh-label">Utformet av</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='KategoriHelsepersonell']">
							<xsl:call-template name="k-9060"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Merknad'] or child::*[local-name()='EvalueringTidspunkt']">
				<div class="eh-col-1">
					<div class="eh-label">Merknad</div>
					<div class="eh-field">
						<xsl:if test="child::*[local-name()='Merknad']">
							<div>
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
								</xsl:call-template>
							</div>
						</xsl:if>
						<xsl:if test="child::*[local-name()='EvalueringTidspunkt']">
							<div>
								<b>Evalueringstidspunkt:</b>&#160;
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='EvalueringTidspunkt']"/>
								</xsl:call-template>
							</div>
						</xsl:if>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Stikkord']">
				<div class="eh-col-1">
					<div class="eh-label">Stikkord</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='Stikkord']">
							<xsl:if test="position()!=1">,&#160;</xsl:if>
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="."/>
							</xsl:call-template>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
		</div>
		<xsl:for-each select=".//child::*[local-name()='GjennomforingAvTiltak']">
			<div class="eh-row-4">
				<div class="eh-col-1">
					<div class="eh-label">Gjennomført tidspunkt</div>
					<div class="eh-field">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="child::*[local-name()='UtfortTidspunkt']"/>
						</xsl:call-template>&#160;
					</div>
				</div>
				<xsl:if test="child::*[local-name()='TiltakKanTermineres']">
					<div class="eh-col-1">
						<div class="eh-label">Kan termineres</div>
						<div class="eh-field">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='TiltakKanTermineres']='true'">Ja</xsl:when>
								<xsl:otherwise>Nei</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Merknad']">
					<div class="eh-col-1">
						<div class="eh-label">Merknad</div>
						<div class="eh-field">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="child::*[local-name()='Merknad']"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
		<xsl:for-each select=".//child::*[local-name()='PlanlagtGjennomforingTiltak']">
			<div class="eh-row-4">
				<div class="eh-col-1">
					<div class="eh-label">Tidsrom</div>
					<div class="eh-field">
						<div>
							<b>Planlagt start:</b>&#160;
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='PlanlagtStart']"/>
							</xsl:call-template>&#160;
						</div>
						<xsl:if test="child::*[local-name()='PlanlagtSlutt']">
							<b>Planlagt slutt:</b>&#160;
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='PlanlagtSlutt']"/>
							</xsl:call-template>&#160;
						</xsl:if>
					</div>
				</div>
				<xsl:if test="child::*[local-name()='FasteUkedager']">
					<div class="eh-col-1">
						<div class="eh-label">Faste ukedager</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='FasteUkedager']">
								<xsl:if test="position()!=1">,&#160;</xsl:if>
								<xsl:call-template name="k-9082"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='GjentagelseIntervall']">
					<div class="eh-col-1">
						<div class="eh-label">GjentagelseIntervall</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='GjentagelseIntervall']/@V"/>&#160;<xsl:value-of select="child::*[local-name()='GjentagelseIntervall']/@U"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='EtterBehov']">
					<div class="eh-col-1">
						<div class="eh-field">
							<xsl:if test="child::*[local-name()='EtterBehov']='true'">Gjentas etter behov</xsl:if>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="RefDoc">
		<xsl:apply-templates select=".">
			<xsl:with-param name="std-col" select="$std-col"/>
			<xsl:with-param name="std-td" select="$std-td"/>
		</xsl:apply-templates>
	</xsl:template>
</xsl:stylesheet>
