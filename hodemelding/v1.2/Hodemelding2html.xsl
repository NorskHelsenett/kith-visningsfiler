<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1" 
	xmlns:dia="http://www.kith.no/xmlstds/dialog/2006-10-11" 
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#" 
	exclude-result-prefixes="mh fk1 dia ds">

<!--
	Inngår i KITHs visningsfiler versjon 10

	FORMÅL
	Felles XSLT for generering av HTML for meldinger med hodemelding
	BRUK
	Importeres vha. <xsl:include href="Hodemelding2html.xsl"/>

	ENDRINGER:
	04.06.2021: Lagt til xsl:output for å definere at output formatet skal være html
	25.10.2016: La til visningsversjonnr
	01.12.2010: Enkelte tabeller erstattet med div-tagger og layout overtatt av CSS
	05.03.2010: Layoutmessige justeringer
	28.04.2009: Måtte ta bort alle div-klasser for å unngå unødig linjeskift i visningsmodus "@media screen"
	06.02.2007: Mhj. id 1211 - feil i visning av fnr fikset
	25.01.2006: Første versjon
-->

	<!-- Denne importeres i hovedfila
	<xsl:import href="../../felleskomponenter/funksjoner.xsl"/>
	-->

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<xsl:template match="mh:MsgHead">
		<xsl:apply-templates/>
	</xsl:template>
	<!-- Meldingshodet - avsender og mottaker-informasjon -->
	<xsl:template match="mh:MsgInfo">
		<div class="Top">
			<div class="Header">
				<div class="HeaderContent">
					<div class="Caption">Avsender &#160;</div>
					<div class="Content">
						<xsl:apply-templates select="mh:Sender/mh:Organisation"/>
					</div>
				</div>
				<xsl:choose>
					<xsl:when test="mh:Patient">
						<div class="HeaderContent">
							<div class="Caption">Pasient &#160;</div>
							<div class="Content">
								<xsl:apply-templates select="mh:Patient"/>
							</div>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div class="HeaderContent">
							<div class="NoScreen">&#160;</div>
						</div>
					</xsl:otherwise>
				</xsl:choose>
				<div class="HeaderContent">
					<div class="Caption">Mottaker &#160;</div>
					<div class="Content">
						<xsl:apply-templates select="mh:Receiver/mh:Organisation"/>
					</div>
				</div>
				<xsl:choose>
					<xsl:when test="mh:OtherReceiver">
						<div class="HeaderContent">
							<div class="Caption">Kopimottaker(e) &#160;</div>
							<div class="Content">
								<xsl:apply-templates select="mh:OtherReceiver"/>
							</div>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div class="HeaderContent">
							<div class="NoScreen">&#160;</div>
						</div>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="mh:Patient" name="Patient">
		<div>
			<xsl:value-of select="mh:GivenName"/>&#160;<xsl:value-of select="mh:MiddleName"/>&#160;<xsl:value-of select="mh:FamilyName"/>&#160;
			<!--** for-each løkke for å få med alle id-er dersom mer en enn id er oppgitt ** -->
			<xsl:for-each select="mh:Ident">
				<!--** Sjekker om id er av type XXX (Annet), da skrives den ikke ut ** -->
				<xsl:if test="not(mh:TypeId/@V='XXX')">
					<span class="strong">
						<xsl:value-of select="mh:TypeId/@V"/>:&#160;</span>
					<xsl:value-of select="substring(mh:Id, 1,6)"/>&#160;<xsl:value-of select="substring(mh:Id, 7)"/>&#160;</xsl:if>
			</xsl:for-each>
		</div>
		<xsl:if test="mh:Nationality">
			<div>
				<span class="strong">Nasjonalitet:&#160;</span>
				<xsl:value-of select="mh:Nationality/@DN"/>&#160;</div>
		</xsl:if>
		<xsl:apply-templates select="mh:Address"/>
		<xsl:apply-templates select="mh:TeleCom"/>
	</xsl:template>
	<xsl:template match="mh:Person">
		<xsl:call-template name="Patient"/>
	</xsl:template>

	<xsl:template match="mh:Organisation">
		<xsl:if test="not(mh:Organisation//mh:HealthcareProfessional)">
			<xsl:apply-templates select="mh:HealthcareProfessional"/>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="local-name(..)!=&quot;Organisation&quot;">
				<div>
					<xsl:value-of select="mh:OrganisationName"/>&#160;</div>
			</xsl:when>
			<xsl:otherwise>
				<div>
					<div class="NoPrint">-&#160;</div>
					<xsl:value-of select="mh:OrganisationName"/>&#160;</div>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="not(mh:Organisation//mh:Address)">
			<xsl:apply-templates select="mh:Address"/>
		</xsl:if>
		<xsl:if test="not(mh:Organisation//mh:TeleCom)">
			<xsl:apply-templates select="mh:TeleCom"/>
		</xsl:if>
		<xsl:if test="mh:Organisation">
			<xsl:apply-templates select="mh:Organisation"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="mh:Address">
		<div class="NoPrint">&#160;<span class="strong">
				<xsl:choose>
					<xsl:when test="mh:Type/@DN">
						<xsl:value-of select="mh:Type/@DN"/>:&#160;</xsl:when>
					<xsl:otherwise>Adresse:&#160;</xsl:otherwise>
				</xsl:choose>
			</span>
		</div>
		<xsl:if test="mh:StreetAdr">
			<div>
				<xsl:value-of select="mh:StreetAdr"/>
			</div>
		</xsl:if>
		<xsl:if test="mh:PostalCode or mh:City">
			<xsl:if test="mh:StreetAdr">
				<div class="NoPrint">,</div>
			</xsl:if>
			<div>
				<xsl:value-of select="mh:PostalCode"/>&#160;<xsl:value-of select="mh:City"/>
			</div>
		</xsl:if>
		<xsl:if test="mh:CityDistr">
			<div class="NoPrint">,</div>
			<div>
				<xsl:value-of select="mh:CityDistr/@DN"/>
			</div>
		</xsl:if>
		<xsl:if test="mh:County">
			<div class="NoPrint">,</div>
			<div>
				<xsl:value-of select="mh:County/@DN"/>
			</div>
		</xsl:if>
		<xsl:if test="mh:Country">
			<div class="NoPrint">,</div>
			<div>
				<xsl:value-of select="mh:Country/@DN"/>
			</div>
		</xsl:if>
		<xsl:for-each select="mh:TeleAddress">
			<div class="NoPrint">&#160;</div>
			<xsl:apply-templates select="."/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="mh:TeleCom">
		<xsl:for-each select="mh:TeleAddress">
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
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="mh:HealthcareProfessional">
		<div>
			<xsl:choose>
				<xsl:when test="mh:RoleToPatient/@DN">
					<xsl:value-of select="mh:RoleToPatient/@DN"/>&#160;
				</xsl:when>
				<xsl:when test="mh:TypeHealthcareProfessional/@DN">
					<xsl:value-of select="mh:TypeHealthcareProfessional/@DN"/>&#160;
				</xsl:when>
			</xsl:choose>
			<xsl:if test="mh:GivenName">
				<xsl:value-of select="mh:GivenName"/>&#160;
			</xsl:if>
			<xsl:if test="mh:MiddleName">
				<xsl:value-of select="mh:MiddleName"/>&#160;
			</xsl:if>
			<xsl:if test="mh:FamilyName">
				<xsl:value-of select="mh:FamilyName"/>&#160;
			</xsl:if>
			<xsl:if test="/.//m1:Spesialitet/@DN" xmlns:m1="http://www.kith.no/xmlstds/eresept/m1/2010-05-01">
				<xsl:value-of select="/.//m1:Spesialitet/@DN"/>&#160;
			</xsl:if>
		</div>
	</xsl:template>
	<xsl:template match="mh:Document">

		<xsl:if test="not(preceding-sibling::mh:Document) and (../mh:MsgInfo/mh:Type/@V='EPJ-EKSTRAKT')">
			<table width="95%" bgcolor="gray" style="padding:0.1em; color:white; background-color:gray; border:1px solid gray; font: 1.6em; font-weight: bold;">
				<tr>
					<td>Legemiddelopplysninger</td>
				</tr>
			</table>
		</xsl:if>
		<xsl:if test="not(mh:RefDoc/mh:Content/epj-s:Node) and not(mh:RefDoc/mh:Content/epj-t:tilleggsinfoEPJKomponent) and not(../mh:MsgInfo/mh:Type/@V='EPJ-EKSTRAKT') and not(mh:RefDoc/mh:Content/bas:Base64Container)" xmlns:epj-s="http://www.kith.no/xmlstds/epj/EPJEkstrakt/2008-02-20" xmlns:epj-t="http://www.kith.no/xmlstds/epj/EPJTilleggsinfo/2008-02-20" xmlns:bas="http://www.kith.no/xmlstds/base64container">
			<!-- HACK for å ikke vise epj-struktur-dokument og tilleggsinfodokument -->
			<div class="{$stil}">
				<xsl:apply-templates select="mh:RefDoc"/>
			</div>
			<div class="{$stil}">
				<h2>Dokumentinformasjon</h2>
				<table>
					<tbody>
						<xsl:if test="mh:ContentType">
							<tr>
								<th>Innholdstype</th>
								<td>
									<xsl:value-of select="mh:ContentType/@DN"/>
								</td>
							</tr>
						</xsl:if>
						<xsl:if test="mh:ContentDescription">
							<tr>
								<th>Innholdsbeskrivelse</th>
								<td>
									<xsl:value-of select="mh:ContentDescription"/>
								</td>
							</tr>
						</xsl:if>
						<xsl:if test="mh:ContentCategory">
							<tr>
								<th>Innholdskategori</th>
								<td>
									<xsl:value-of select="mh:ContentCategory/@DN"/>
								</td>
							</tr>
						</xsl:if>
						<xsl:if test="mh:Consent">
							<tr>
								<th>Samtykke</th>
								<td>
									<xsl:value-of select="mh:Consent/@DN"/>
								</td>
							</tr>
						</xsl:if>
						<xsl:if test="mh:Annotation">
							<tr>
								<th>Merknad</th>
								<td>
									<xsl:value-of select="mh:Annotation"/>
								</td>
							</tr>
						</xsl:if>
						<xsl:if test="mh:FromDate">
							<tr>
								<th>Tidligste registrering</th>
								<td>
									<xsl:value-of select="substring(mh:FromDate/@V,1,10)"/>&#160;<xsl:value-of select="substring(mh:FromDate/@V,12,5)"/>
								</td>
							</tr>
						</xsl:if>
						<xsl:if test="mh:ToDate">
							<tr>
								<th>Seneste registrering</th>
								<td>
									<xsl:value-of select="substring(mh:ToDate/@V,1,10)"/>&#160;<xsl:value-of select="substring(mh:ToDate/@V,12,5)"/>
								</td>
							</tr>
						</xsl:if>
						<xsl:if test="mh:RefDoc/mh:IssueDate">
							<tr>
								<th>Utstedelsestidspunkt</th>
								<td>
									<xsl:value-of select="substring(mh:RefDoc/mh:IssueDate/@V,1,10)"/>&#160;<xsl:value-of select="substring(mh:RefDoc/mh:IssueDate/@V,12,5)"/>
								</td>
							</tr>
							<!--<xsl:value-of select="mh:RefDoc/mh:IssueDate/@V"/>-->
						</xsl:if>
						<xsl:if test="mh:RefDoc//po:InformasjonOmForsendelsen" xmlns:po="http://www.kith.no/xmlstds/po/poKomponent/2009-06-30">
							<tr>
								<th>Informasjon om forsendelsen</th>
								<td>
									<xsl:for-each select="mh:RefDoc//po:InformasjonOmForsendelsen">
										<xsl:if test="po:Forsendelsesstatus">
											Forsendelsesstatus:&#160;<xsl:value-of select="po:Forsendelsesstatus/@DN"/>
										</xsl:if>
										<xsl:if test="po:ForbeholdOmVideresending">
											<br/>
											<xsl:if test="po:ForbeholdOmVideresending = 'true'">
												Pasienten tillater ikke videresending av informasjonen.
											</xsl:if>
											<xsl:if test="po:ForbeholdOmVideresending = 'false'">
												Pasienten tillater videresending av informasjonen.
											</xsl:if>
										</xsl:if>
									</xsl:for-each>
								</td>
							</tr>
						</xsl:if>
						<tr>
							<th width="100px">Melding opprettet:</th>
							<td>
								<xsl:value-of select="substring(../mh:MsgInfo/mh:GenDate,1,10)"/>&#160;<xsl:value-of select="substring(../mh:MsgInfo/mh:GenDate,12,5)"/>
							</td>
						</tr>
						<tr>
							<th>Meldingsid:</th>
							<td>
								<xsl:value-of select="../mh:MsgInfo/mh:MsgId"/>
							</td>
						</tr>
						<tr>
							<th>Visningsversjon</th>
							<td>
								<xsl:value-of select="$versjon"/>
							</td>
						</tr>
					</tbody>
				</table>
				<!-- Alternativ måte å vise dokumentinformasjonen hvor elementene flyter etter hverandre:
				<div class="Header">
					<xsl:if test="mh:ContentType">
						<div class="Block">
							<div class="MainCaption">Innholdstype</div>
							<div class="MainContent"><xsl:value-of select="mh:ContentType"/></div>
						</div>
					</xsl:if>
					<xsl:if test="mh:ContentDescription">
						<div class="Block">
							<div class="MainCaption">Innholdsbeskrivelse</div>
							<div class="MainContent"><xsl:value-of select="mh:ContentDescription"/></div>
						</div>
					</xsl:if>
					<xsl:if test="mh:ContentCategory">
						<div class="Block">
							<div class="MainCaption">Innholdskategori</div>
							<div class="MainContent"><xsl:value-of select="mh:ContentCategory/@DN"/></div>
						</div>
					</xsl:if>
					<xsl:if test="mh:Consent">
						<div class="Block">
							<div class="MainCaption">Samtykke</div>
							<div class="MainContent"><xsl:value-of select="mh:Consent/@DN"/></div>
						</div>
					</xsl:if>
					<xsl:if test="mh:Annotation">
						<div class="Block">
							<div class="MainCaption">Merknad</div>
							<div class="MainContent"><xsl:value-of select="mh:Annotation"/></div>
						</div>
					</xsl:if>
					<xsl:if test="mh:FromDate">
						<div class="Block">
							<div class="MainCaption">Tidligste registrering</div>
							<div class="MainContent"><xsl:value-of select="mh:FromDate"/></div>
						</div>
					</xsl:if>
					<xsl:if test="mh:ToDate">
						<div class="Block">
							<div class="MainCaption">Seneste registrering</div>
							<div class="MainContent"><xsl:value-of select="mh:ToDate"/></div>
						</div>
					</xsl:if>
					<xsl:if test="mh:RefDoc/mh:IssueDate">
						<div class="Block">
							<div class="MainCaption">Utstedelsestidspunkt</div>
							<div class="MainContent"><xsl:call-template name="skrivUtDateTime"><xsl:with-param name="oppgittTid" select="mh:RefDoc/mh:IssueDate/@V"></xsl:with-param></xsl:call-template></div>
						</div>
					</xsl:if>
					<xsl:if test="../mh:MsgInfo/mh:GenDate">
						<div class="Block">
							<div class="MainCaption">Melding sendt</div>
							<div class="MainContent"><xsl:call-template name="skrivUtDateTime"><xsl:with-param name="oppgittTid" select="../mh:MsgInfo/mh:GenDate"></xsl:with-param></xsl:call-template></div>
						</div>
					</xsl:if>
					<xsl:if test="../mh:MsgInfo/mh:MsgId">
						<div class="Block">
							<div class="MainCaption">Meldingsid</div>
							<div class="MainContent"><xsl:value-of select="../mh:MsgInfo/mh:MsgId"/></div>
						</div>
					</xsl:if>
					<xsl:if test="mh:RefDoc//po:InformasjonOmForsendelsen" xmlns:po="http://www.kith.no/xmlstds/po/poKomponent/2009-06-30">
						<div class="Block">
							<div class="MainCaption">Informasjon om forsendelsen</div>
							<div class="MainContent">
								<xsl:for-each select="mh:RefDoc//po:InformasjonOmForsendelsen">
									<xsl:if test="po:Forsendelsesstatus">
										Forsendelsesstatus:&#160;<xsl:value-of select="po:Forsendelsesstatus/@DN"/>
									</xsl:if>
									<xsl:if test="po:ForbeholdOmVideresending">
										<br/>
										<xsl:if test="po:ForbeholdOmVideresending = 'true'">
											Pasienten tillater ikke videresending av informasjonen.
										</xsl:if>
										<xsl:if test="po:ForbeholdOmVideresending = 'false'">
											Pasienten tillater videresending av informasjonen.
										</xsl:if>
									</xsl:if>
								</xsl:for-each>
							</div>
						</div>
					</xsl:if>
				</div> -->
			</div>
		</xsl:if>
		<!--** Test for å sjekke om meldingstypen er EPJ-ekstrakt ** -->
		<xsl:if test="not(mh:RefDoc/mh:Content/epj-s:Node) and not(mh:RefDoc/mh:Content/epj-t:tilleggsinfoEPJKomponent) and (../mh:MsgInfo/mh:Type/@V='EPJ-EKSTRAKT')" xmlns:epj-s="http://www.kith.no/xmlstds/epj/EPJEkstrakt/2008-02-20" xmlns:epj-t="http://www.kith.no/xmlstds/epj/EPJTilleggsinfo/2008-02-20">
			<div class="{$stil}">
				<xsl:apply-templates select="mh:RefDoc"/>
			</div>
			<xsl:if test="mh:RefDoc/mh:IssueDate">
				<div class="{$stil}">
					<h2>Dokumentinformasjon:</h2>
					<table>
						<tbody>
							<tr>
								<th width="5%">Utstedelsestidspunkt</th>
								<td>
									<xsl:value-of select="substring(mh:RefDoc/mh:IssueDate/@V,1,10)"/>&#160;<xsl:value-of select="substring(mh:RefDoc/mh:IssueDate/@V,12,5)"/>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<xsl:template match="mh:RefDoc">
		<xsl:apply-templates select="mh:Content"/>
	</xsl:template>
	<xsl:template match="mh:Content">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="ds:Signature">
		<!--<xsl:apply-templates/>-->
	</xsl:template>
	<!-- Skriver ut opprinnelig forespørsel dersom denne er lagt ved når meldingstypen er EPJ-ekstrakt -->
	<xsl:template match="dia:Foresporsel">
		<h2>Mottatt forespørsel</h2>
		<xsl:if test="(../../../../../mh:MsgInfo/mh:Type/@V='EPJ-EKSTRAKT')">
			<table width="80%">
				<tbody>
					<tr>
						<th width="20%">Type forespørsel</th>
						<td colspan="5">
							<xsl:value-of select="dia:TypeForesp/@DN"/>
						</td>
					</tr>
					<xsl:if test="dia:Hastegrad">
						<tr>
							<th>Hastegrad</th>
							<td colspan="5">
								<xsl:value-of select="dia:Hastegrad/@DN"/>
							</td>
						</tr>
					</xsl:if>
					<xsl:if test="dia:Formål or dia:Begrunnelse">
						<tr>
							<th>Formål (kodet)</th>
							<td>
								<xsl:value-of select="dia:Formål/@DN"/>
							</td>
							<th>Utdyping av formål</th>
							<td colspan="3">
								<xsl:value-of select="dia:Begrunnelse"/>
							</td>
						</tr>
					</xsl:if>
					<xsl:if test="dia:typeJournalinfo or dia:FraDato or dia:TilDato">
						<tr>
							<th>Type journalinformasjon</th>
							<td>
								<xsl:value-of select="dia:TypeJournalinfo/@DN"/>
							</td>
							<th>Fra dato</th>
							<td>
								<xsl:value-of select="dia:FraDato"/>
							</td>
							<th>Til dato</th>
							<td>
								<xsl:value-of select="dia:TilDato"/>
							</td>
						</tr>
					</xsl:if>
					<tr>
						<td colspan="6">
							<xsl:choose>
								<xsl:when test="count(dia:DiaSporsmal/*) &lt; 1">
									<xsl:call-template name="line-breaks">
										<xsl:with-param name="text" select="dia:Sporsmal"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:for-each select="dia:Sporsmal">
										<xsl:apply-templates/>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<xsl:apply-templates select="dia:RollerRelatertNotat"/>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
