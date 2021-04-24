function [tierNames, tierCell]= readTextGrid(path)
fid=fopen(path);
myArr=textscan(fid, '%s');
fclose(fid);
myArr=myArr{1};
i=1;
allTierNames={};allTierIdxs=[];
intervalCell={};pointCell={};
while i<=size(myArr,1)

    while strmatch('"',myArr{i}) & (length(myArr{i})==1 | ~strcmp(myArr{i}(1),myArr{i}(end)))
        myArr{i}=cat(2,myArr{i},myArr{i+1});
        myArr(i+1)=[];
    end
    i=i+1;
end
startOfIntervals=find(ismember(myArr, 'intervals:')==1);
startOfPoints=find(ismember(myArr, 'points:')==1);
namesIdxs=find(ismember(myArr, 'name')==1);

% alternative: startOfIntervals=find(strncmp(myArr, 'intervals:'));
rowWithNOI=startOfIntervals+3;
nois=myArr(rowWithNOI); % number of intervals

for tiern=1:length(nois)
    [~,thisIDx]=min(abs(rowWithNOI(tiern)-namesIdxs));
    allTierNames=cat(2, allTierNames,myArr(namesIdxs(thisIDx)+2));
    allTierIdxs=[allTierIdxs,thisIDx];
    
    noi=str2double(nois{tiern,1});
    lastaib=startOfIntervals(tiern)-3;
    intervalCell{tiern}=cell(noi,3);
    for icIndex=1:noi
          aib=lastaib+11;
%           aib=icIndex*11; % array index base
          xmin=myArr(aib);
          xmax=myArr(aib+3);
          text=myArr(aib+6);
          intervalCell{tiern}(icIndex,:)={str2double(xmin{1,1}),str2double(xmax{1,1}),regexprep(text{1,1}, '"', '')};
    lastaib=aib;
    end 
end

startOfPoints=find(ismember(myArr, 'points:')==1);
rowWithNOP=startOfPoints+3;
nops=myArr(rowWithNOP); % number of points

for tiern=1:length(nops)
    [~,thisIDx]=min(abs(rowWithNOP(tiern)-namesIdxs));
    allTierNames=cat(2, allTierNames,myArr(namesIdxs(thisIDx)+2));
    allTierIdxs=[allTierIdxs,thisIDx];
    noi=str2double(nops{tiern,1});
    lastaib=startOfPoints(tiern);
    pointCell{tiern}=cell(noi,3);
    for icIndex=1:noi
          aib=lastaib+8;
%           aib=icIndex*11; % array index base
          x=myArr(aib);
          text=myArr(aib+3);
          pointCell{tiern}(icIndex,:)={str2double(x{1,1}),str2double(x{1,1}),regexprep(text{1,1}, '"', '')};
          lastaib=aib;
    end 
end
    tierCell={intervalCell{:},pointCell{:}};

[~,newIdxs]=sort(allTierIdxs);
tierCell=tierCell(newIdxs);
tierNames=allTierNames(newIdxs);


