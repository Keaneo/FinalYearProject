function anatData = prepare_anat_data(s, nProbe)
    inclCID = find(s.clusters.probes==nProbe-1)-1;
    coords = s.channels.sitePositions(s.channels.probe==nProbe-1,:);
    acr = s.channels.brainLocation.allen_ontology(s.channels.probe==nProbe-1,:);
    lowerBorder = 0; upperBorder = []; acronym = {acr(1,:)};
    for q = 2:size(acr,1)
        if ~strcmp(acr(q,:), acronym{end})
            upperBorder(end+1) = coords(q,2); 
            lowerBorder(end+1) = coords(q,2); 
            acronym{end+1} = acr(q,:);
        end
    end
    upperBorder(end+1) = max(coords(:,2));
    upperBorder = upperBorder'; lowerBorder = lowerBorder'; acronym = acronym';
    anatData = struct('borders', table(upperBorder, lowerBorder, acronym));
end
