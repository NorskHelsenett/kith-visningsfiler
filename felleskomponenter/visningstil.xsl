<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	exclude-result-prefixes="">

	<xsl:output method="html" version="4.01" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" 
		doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

	<xsl:param name="visningStil"/> <!-- Alternative verdier : Document, Smooth, One-line-doc, No-line-doc -->

	<!-- Variabel for hvilken stil visningen har. Tilgjengelige stiler er: Document, 'Document Smooth', One-line-doc, No-line-doc -->
	<xsl:variable name="stil">
		<xsl:choose>
			<xsl:when test="$visningStil">
				<xsl:choose>
					<xsl:when test="$visningStil = 'Smooth'" ><xsl:value-of select="'Document Smooth'"/></xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$visningStil != 'Document' and $visningStil != 'One-line-doc' and $visningStil != 'No-line-doc'">
								<xsl:value-of select="'Document Smooth'"/><!-- feil parameter-verdi oppgitt, velg default -->
							</xsl:when>
							<xsl:otherwise><xsl:value-of select="$visningStil"/></xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="'Document Smooth'"/></xsl:otherwise><!-- ingen parameter oppgitt, velg default -->
		</xsl:choose>
	</xsl:variable>

</xsl:stylesheet>