const getProxyPdfUrl = (state, attachmentKey) => {
	const base = state?.config?.pdfProxyBaseUrl;
	if (!base || !attachmentKey) {
		return null;
	}
	const items = state.libraries?.[state.current?.libraryKey]?.items ?? {};
	const item = items[attachmentKey];
	const contentType = item?.contentType;
	if (contentType !== 'application/pdf') {
		return null;
	}
	return `${base.replace(/\/$/, '')}/${attachmentKey}`;
};

export { getProxyPdfUrl };

