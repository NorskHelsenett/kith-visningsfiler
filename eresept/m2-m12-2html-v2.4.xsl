<?xml version="1.0" encoding="UTF-8"?>
<!-- 
	Visningsfil for eReseptmeldingen M2 Individuell søknad om refusjon til HELFO
	Visningen håndterer vedlegg av en eller flere M12 Søknadssvar - Individuell søknad om refusjon til HELFO
	Inngår i KITHs visningsfiler versjon 10

	04-06-2021: v3.1.3: La til xsl:output for å definere at output formatet skal være html
	09-05-2017: v3.1.2: Rettet formell test på tekst mot number
	27-03-2017: v3.1.1: Ny parameter for "visningStil". Ny stil "Smooth".
	25-10-2016: v3.1.0: La til variabel for visningsversjonnr
	11-02-2011: Første versjon

	MERK:
	Bygger på visningsfil for hodemeldingen - denne må være tilstede. 
-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1" 
	xmlns:m2="http://www.kith.no/xmlstds/eresept/m2/2010-07-01" 
	xmlns:m12="http://www.kith.no/xmlstds/eresept/m12/2010-07-01" 
	xmlns:fs="http://www.kith.no/xmlstds/eresept/forskrivning/2010-04-01" 
	exclude-result-prefixes="mh fk1 m2 m12 fs">

	<xsl:import href="../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../felleskomponenter/visningstil.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<xsl:include href="../hodemelding/v1.2/Hodemelding2html.xsl"/>

	
	<!-- Vedlegg i denne sammenhengen er en eller flere m12-meldinger -->
	<xsl:param name="vedlegg"/>

	<xsl:variable name="antall-legemidler" select="count(//m2:OmsoktLegemiddel)"/>
	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'eresept-m2-2.4 - v3.1.3'"/>
	
	<xsl:template match="/">
		<html>
			<head>
				<title>M02 - Individuell søknad om refusjon til HELFO</title>
				<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
				<style type="text/css">
					<xsl:value-of select="document('../felleskomponenter/KITH-visning.css')" disable-output-escaping="yes" />
				</style>
				<style type="text/css">
					<xsl:value-of select="document('../felleskomponenter/smooth-visning.css')" disable-output-escaping="yes"/>
				</style>
			</head>
			<body>
				<xsl:apply-templates>
					<xsl:with-param name="visningStil" select="$stil"/>
				</xsl:apply-templates>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="m2:SoknadNav">
		<h1>M02 - Individuell søknad om refusjon til HELFO</h1>
		<p/>
		<xsl:choose>
			<xsl:when test="$antall-legemidler=1">
				<h2>Omsøkt legemiddel</h2>
			</xsl:when>
			<xsl:when test="$antall-legemidler &gt; 1">
				<h2>Omsøkte legemidler</h2>
			</xsl:when>
		</xsl:choose>
		<xsl:for-each select="//m2:OmsoktLegemiddel">
			<xsl:apply-templates select="."/>
		</xsl:for-each>
		<xsl:for-each select="//m2:SoknadNaringsmiddel">
			<xsl:apply-templates select="."/>
		</xsl:for-each>
		<xsl:if test="//m2:TidligereBeh">
			<xsl:if test="//m2:SoknadNaringsmiddel"><h2>Tidligere brukte næringsmidler</h2></xsl:if>
			<xsl:if test="//m2:OmsoktLegemiddel"><h2>Tidligere brukte legemidler</h2></xsl:if>
			<table><tbody>
				<xsl:for-each select="//m2:TidligereBeh"><xsl:apply-templates select="."/></xsl:for-each>
			</tbody></table>
		</xsl:if>
		<p/>
		<table><tbody>
			<tr>
				<td width="50%">
					<h2>Diagnoser</h2>
					<table><tbody>
						<tr>
							<td><xsl:value-of select="m2:Diagnose/@DN"/></td>
						</tr>
						<xsl:for-each select="m2:Bidiagnose">
							<tr>
								<td><xsl:value-of select="@DN"/></td>
							</tr>
						</xsl:for-each>
					</tbody></table>
				</td>
				<td width="50%" valign="top">
					<h2>Refusjon</h2>
					<table><tbody>
						<tr>
							<td><xsl:value-of select="m2:RefHjemmel/@DN"/></td>
						</tr>
					</tbody></table>
				</td>
			</tr>
		</tbody></table>
		<h2>Relevant informasjon</h2>
		<table><tbody>
			<xsl:if test="m2:Begrunnelse or m2:Merknad">
				<tr>
					<xsl:if test="m2:Begrunnelse"><th width="25%">Begrunnelse</th></xsl:if>
					<xsl:if test="m2:Merknad"><th width="25%">Merknad</th></xsl:if>
				</tr>
				<tr>
					<xsl:if test="m2:Begrunnelse"><td width="25%"><xsl:value-of select="m2:Begrunnelse"/></td></xsl:if>
					<xsl:if test="m2:Merknad"><td width="25%"><xsl:value-of select="m2:Merknad"/></td></xsl:if>
				</tr>
			</xsl:if>
			<xsl:if test="m2:KroniskSykdom or m2:LangvarigBeh or m2:BrukUtenforSykehus">
				<tr>
					<xsl:if test="m2:KroniskSykdom"><td width="25%">
						<xsl:choose>
							<xsl:when test="m2:KroniskSykdom/@V = '1'"><input type="checkbox" disabled="disabled" checked="checked">Kronisk sykdom</input></xsl:when>
							<xsl:otherwise><input type="checkbox" disabled="disabled">Kronisk sykdom</input></xsl:otherwise>
						</xsl:choose>
					</td></xsl:if>
					<xsl:if test="m2:LangvarigBeh"><td width="25%">
						<xsl:choose>
							<xsl:when test="m2:LangvarigBeh/@V = '1'"><input type="checkbox" disabled="disabled" checked="checked">Langvarig behandling</input></xsl:when>
							<xsl:otherwise><input type="checkbox" disabled="disabled">Langvarig behandling</input></xsl:otherwise>
						</xsl:choose>
					</td></xsl:if>
					<xsl:if test="m2:BrukUtenforSykehus"><td width="25%">
						<xsl:choose>
							<xsl:when test="m2:BrukUtenforSykehus/@V = '1'"><input type="checkbox" disabled="disabled" checked="checked">Bruk utenfor sykehus</input></xsl:when>
							<xsl:otherwise><input type="checkbox" disabled="disabled">Bruk utenfor sykehus</input></xsl:otherwise>
						</xsl:choose>
					</td></xsl:if>
				</tr>
			</xsl:if>
			<xsl:if test="m2:SamPasient or m2:SamVedtak or m2:Forstegangs">
				<tr>
					<xsl:if test="m2:SamPasient"><td width="25%">
						<xsl:choose>
							<xsl:when test="m2:SamPasient/@V = '1'"><input type="checkbox" disabled="disabled" checked="checked">Samtykke</input></xsl:when>
							<xsl:otherwise><input type="checkbox" disabled="disabled">Samtykke</input></xsl:otherwise>
						</xsl:choose>
					</td></xsl:if>
					<xsl:if test="m2:SamVedtak"><td width="25%">
						<xsl:choose>
							<xsl:when test="m2:SamVedtak/@V = '1'"><input type="checkbox" disabled="disabled" checked="checked">Samtykke kopi</input></xsl:when>
							<xsl:otherwise><input type="checkbox" disabled="disabled">Samtykke kopi</input></xsl:otherwise>
						</xsl:choose>
					</td></xsl:if>
					<xsl:if test="m2:Forstegangs"><td width="25%">
						<xsl:choose>
							<xsl:when test="m2:Forstegangs/@V = '1'"><input type="checkbox" disabled="disabled" checked="checked">Førstegangssøknad</input></xsl:when>
							<xsl:otherwise><input type="checkbox" disabled="disabled">Førstegangssøknad</input></xsl:otherwise>
						</xsl:choose>
					</td></xsl:if>
				</tr>
			</xsl:if>
		</tbody></table>
		<xsl:for-each select="m2:Vedlegg">
			<xsl:choose>
				<xsl:when test="position() = 1">
					<tr><th>Vedlegg</th></tr>
					<tr><td><xsl:value-of select="."/></td></tr>
				</xsl:when>
				<xsl:otherwise>
					<tr><td><xsl:value-of select="."/></td></tr>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:if test="m2:Instituert or m2:Institueringstidspunkt">
			<h2>Instituert av</h2>
			<table><tbody>
				<tr>
					<xsl:if test="m2:Instituert"><th width="25%">Navn</th></xsl:if>
					<xsl:if test="m2:Institueringstidspunkt"><th width="25%">Institueringstidspunkt</th></xsl:if>
				</tr>
				<tr>
					<xsl:if test="m2:Instituert"><td width="25%">
						<xsl:if test="m2:Instituert/m2:Helseperson">
							<xsl:value-of select="m2:Instituert/m2:Helseperson/m2:Fornavn"/>&#160;<xsl:value-of select="m2:Instituert/m2:Helseperson/m2:Etternavn"/>
							<xsl:if test="m2:Instituert/m2:Organisasjon/m2:Inst">&#160;&#160;</xsl:if>
						</xsl:if>
						<xsl:if test="m2:Instituert/m2:Organisasjon/m2:Inst">
							<xsl:value-of select="m2:Instituert/m2:Organisasjon/m2:Inst"/>&#160;<xsl:value-of select="m2:Instituert/m2:Organisasjon/m2:Dept"/>
						</xsl:if>
					</td></xsl:if>
					<xsl:if test="m2:Institueringstidspunkt"><td width="25%"><xsl:value-of select="m2:Institueringstidspunkt"/></td></xsl:if>
				</tr>
			</tbody></table>
		</xsl:if>
		<xsl:if test="string-length($vedlegg) != 0"><xsl:apply-templates select="$vedlegg//m12:Soknadssvar"/></xsl:if>
	</xsl:template>
	
	<xsl:template match="m2:OmsoktLegemiddel">
		<xsl:variable name="refId">
			<xsl:choose>
				<xsl:when test="$antall-legemidler=1"><xsl:value-of select="/.//mh:MsgId"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="m2:Uuid"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<table>
			<tbody>
				<xsl:if test="fs:LegemiddelMerkevare/fs:Reseptgruppe/@DN or fs:LegemiddelMerkevare/fs:NavnFormStyrke or string-length($vedlegg) != 0">
					<tr>
						<xsl:if test="fs:LegemiddelMerkevare/fs:Reseptgruppe/@DN"><th width="25%">Reseptgruppe</th></xsl:if>
						<xsl:if test="fs:LegemiddelMerkevare/fs:NavnFormStyrke"><th width="25%">NavnFormStyrke</th></xsl:if>
						<xsl:if test="string-length($vedlegg) != 0"><th width="25%">Søknadssvar</th></xsl:if>
					</tr>
					<tr>
						<xsl:if test="fs:LegemiddelMerkevare/fs:Reseptgruppe/@DN"><td width="25%"><xsl:value-of select="fs:LegemiddelMerkevare/fs:Reseptgruppe/@DN"/></td></xsl:if>
						<xsl:if test="fs:LegemiddelMerkevare/fs:NavnFormStyrke"><td width="25%"><xsl:value-of select="fs:LegemiddelMerkevare/fs:NavnFormStyrke"/></td></xsl:if>
						<xsl:if test="string-length($vedlegg) != 0"><td width="25%">
							<xsl:choose>
								<xsl:when test="count($vedlegg//m12:Soknadssvar) != 0">
									<xsl:choose>
										<xsl:when test="count($vedlegg//m12:Soknadssvar[$refId = m12:RefSoknad]) != 0">
											<xsl:value-of select="$vedlegg//m12:Soknadssvar[$refId = m12:RefSoknad]/m12:Beslutning/@DN"/>
										</xsl:when>
										<xsl:otherwise>
											Mangler vedlagt søknadssvar med samsvarende referanse
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									Mangler vedlagt søknadssvar
								</xsl:otherwise>
							</xsl:choose>
						</td></xsl:if>
					</tr>
				</xsl:if>
			</tbody>
		</table>
		<p/>
	</xsl:template>
	
	<xsl:template match="m2:SoknadNaringsmiddel">
		<h2>Omsøkt næringsmiddel</h2>
		<xsl:variable name="refId" select="/.//mh:MsgId"/>
		<table>
			<tbody>
				<xsl:if test="m2:Produktgruppe/@DN or m2:Varenavn or string-length($vedlegg) != 0">
					<tr>
						<xsl:if test="m2:Produktgruppe/@DN"><th width="25%">Produktgruppe</th></xsl:if>
						<xsl:if test="m2:Varenavn"><th width="25%">Varenavn</th></xsl:if>
						<xsl:if test="string-length($vedlegg) != 0"><th width="25%">Søknadssvar</th></xsl:if>
					</tr>
					<tr>
						<xsl:if test="m2:Produktgruppe/@DN"><td width="25%"><xsl:value-of select="m2:Produktgruppe/@DN"/></td></xsl:if>
						<xsl:if test="m2:Varenavn"><td width="25%"><xsl:value-of select="m2:Varenavn"/></td></xsl:if>
						<xsl:if test="string-length($vedlegg) != 0"><td width="25%">
							<xsl:choose>
								<xsl:when test="count($vedlegg//m12:Soknadssvar) != 0">
									<xsl:choose>
										<xsl:when test="count($vedlegg//m12:Soknadssvar[$refId = m12:RefSoknad]) != 0">
											<xsl:value-of select="$vedlegg//m12:Soknadssvar[$refId = m12:RefSoknad]/m12:Beslutning/@DN"/>
										</xsl:when>
										<xsl:otherwise>
											Mangler vedlagt søknadssvar med samsvarende referanse
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									Mangler vedlagt søknadssvar
								</xsl:otherwise>
							</xsl:choose>
						</td></xsl:if>
					</tr>
				</xsl:if>
				<xsl:if test="m2:Beskrivelse">
					<tr>
						<th width="25%">Beskrivelse</th>
					</tr>
					<tr>
						<td width="25%"><xsl:value-of select="m2:Beskrivelse"/></td>
					</tr>
				</xsl:if>
			</tbody>
		</table>
		<p/>
	</xsl:template>
	
	<xsl:template match="m2:TidligereBeh">
		<xsl:if test="m2:Varenavn or m2:Beskrivelse">
			<tr>
				<xsl:if test="m2:Varenavn"><th width="25%">Varenavn</th></xsl:if>
				<xsl:if test="m2:Beskrivelse"><th width="25%">Beskrivelse</th></xsl:if>
			</tr>
			<tr>
				<xsl:if test="m2:Varenavn"><td width="25%"><xsl:value-of select="m2:Varenavn"/></td></xsl:if>
				<xsl:if test="m2:Beskrivelse"><td width="25%"><xsl:value-of select="m2:Beskrivelse"/></td></xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="fs:LegemiddelMerkevare or m2:SarligeGrunner">
			<tr>
				<xsl:if test="fs:LegemiddelMerkevare"><th width="25%">NavnFormStyrke</th></xsl:if>
				<xsl:if test="m2:SarligeGrunner/@DN"><th width="25%">Særlige grunner</th></xsl:if>
			</tr>
			<tr>
				<xsl:if test="fs:LegemiddelMerkevare"><td width="25%"><xsl:value-of select="fs:LegemiddelMerkevare/fs:NavnFormStyrke"/></td></xsl:if>
				<xsl:if test="m2:SarligeGrunner/@DN"><td width="25%"><xsl:value-of select="m2:SarligeGrunner/@DN"/></td></xsl:if>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="m12:Soknadssvar">
		<h2>M12 - Søknadssvar</h2>
		<table><tbody>
			<xsl:if test="m12:OmsoktVare or m12:Begrunnelse">
				<tr>
					<xsl:if test="m12:OmsoktVare"><th width="25%">Omsøkt vare</th></xsl:if>
					<xsl:if test="m12:Begrunnelse"><th width="25%">Begrunnelse</th></xsl:if>
				</tr>
				<tr>
					<xsl:if test="m12:OmsoktVare"><td width="25%"><xsl:value-of select="m12:OmsoktVare"/></td></xsl:if>
					<xsl:if test="m12:Begrunnelse"><td width="25%"><xsl:value-of select="m12:Begrunnelse"/></td></xsl:if>
				</tr>
			</xsl:if>
			<xsl:if test="m12:Beslutning or m12:Avslagsgrunn or m12:Vedtaksdato">
				<tr>
					<xsl:if test="m12:Beslutning/@DN"><th width="25%">Beslutning</th></xsl:if>
					<xsl:if test="m12:Avslagsgrunn/@DN"><th width="25%">Avslagsgrunn</th></xsl:if>
					<xsl:if test="m12:Vedtaksdato"><th width="25%">Vedtaksdato</th></xsl:if>
				</tr>
				<tr>
					<xsl:if test="m12:Beslutning/@DN"><td width="25%"><xsl:value-of select="m12:Beslutning/@DN"/></td></xsl:if>
					<xsl:if test="m12:Avslagsgrunn/@DN"><td width="25%"><xsl:value-of select="m12:Avslagsgrunn/@DN"/></td></xsl:if>
					<xsl:if test="m12:Vedtaksdato"><td width="25%"><xsl:value-of select="m12:Vedtaksdato"/></td></xsl:if>
				</tr>
			</xsl:if>
			<xsl:for-each select="m12:VedtaketOmfatter">
				<tr><td><h2>Vedtaket omfatter</h2></td></tr>
				<xsl:if test="m12:Varenavn or m12:ProdGruppe or m12:DoseDognMaks">
					<tr>
						<xsl:if test="m12:Varenavn"><th width="25%">Varenavn</th></xsl:if>
						<xsl:if test="m12:ProdGruppe/@DN or m12:ProdGruppe/@OT"><th width="25%">Gruppe</th></xsl:if>
						<xsl:if test="m12:DoseDognMaks"><th width="25%">Maks døgndose</th></xsl:if>
					</tr>
					<tr>
						<xsl:if test="m12:Varenavn"><td width="25%"><xsl:value-of select="m12:Varenavn"/></td></xsl:if>
						<xsl:if test="m12:ProdGruppe/@DN or m12:ProdGruppe/@OT"><td width="25%"><xsl:value-of select="m12:ProdGruppe/@OT"/>&#160;<xsl:value-of select="m12:ProdGruppe/@DN"/></td></xsl:if>
						<xsl:if test="m12:DoseDognMaks"><td width="25%"><xsl:value-of select="m12:DoseDognMaks/@V"/><xsl:value-of select="m12:DoseDognMaks/@U"/></td></xsl:if>
					</tr>
				</xsl:if>
				<xsl:if test="m12:RefHjemmel or m12:RefKode or m12:GyldigTil">
					<tr>
						<xsl:if test="m12:RefHjemmel/@DN or m12:RefHjemmel/@OT"><th width="25%">Refusjonshjemmel</th></xsl:if>
						<xsl:if test="m12:RefKode/@DN or m12:RefKode/@OT"><th width="25%">Ref.kode</th></xsl:if>
						<xsl:if test="m12:GyldigTil"><th width="25%">Gyldig til</th></xsl:if>
					</tr>
					<tr>
						<xsl:if test="m12:RefHjemmel/@DN or m12:RefHjemmel/@OT"><td width="25%"><xsl:value-of select="m12:RefHjemmel/@OT"/>&#160;<xsl:value-of select="m12:RefHjemmel/@DN"/></td></xsl:if>
						<xsl:if test="m12:RefKode/@DN or m12:RefKode/@OT"><td width="25%"><xsl:value-of select="m12:RefKode/@OT"/>&#160;<xsl:value-of select="m12:RefKode/@DN"/></td></xsl:if>
						<xsl:if test="m12:GyldigTil"><td width="25%"><xsl:value-of select="m12:GyldigTil"/></td></xsl:if>
					</tr>
				</xsl:if>
			</xsl:for-each>
		</tbody></table>
	</xsl:template>
</xsl:stylesheet>
