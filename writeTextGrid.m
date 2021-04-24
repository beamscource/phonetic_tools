function writeTextGrid(outpath,outdata,xmin,xmax)

ntiers=length(outdata);
for i=1:ntiers
    tiernames{i}=outdata{i}{1,4};
end
strings{1}=sprintf(...
    'File type = "ooTextFile"\nObject class = "TextGrid"\n\nxmin = %f\nxmax = %f\ntiers? <exists>\n'...
    ,xmin,xmax); 
strings{1}=sprintf('%ssize = %d\nitem []:\n',strings{1},ntiers); 
n=1;
for i=1:ntiers
   n=n+1;
   strings{n}=sprintf('item[%d]\n',i);
   ispoint=0;
   if outdata{i}{1,1}==outdata{i}{1,2}
      strings{n}=sprintf('%sclass = "TextTier"\nname = "%s"\nxmin = %f\nxmax = %f\npoints: size = %d\n',...
       strings{n},tiernames{i},xmin,xmax,length(outdata{i}));
      for j=1:length(outdata{i})
           strings{n}=sprintf('%spoints [%d]:\nnumber = %f\nmark = "%s"\n',... 
            strings{n},j,outdata{i}{j,1},outdata{i}{j,3})
        end
   else
       
       if outdata{i}{1,1}>xmin
           outdata{i}=cat(1,{[xmin],[outdata{i}{1,1}],'',outdata{i}{1,4}},outdata{i});
       end
       gapidxs=find(abs([outdata{i}{2:end,1}]-[outdata{i}{1:end-1,2}])>0);
       if length(gapidxs)>0
           for j=1:length(gapidxs)
                outdata{i}=cat(1,outdata{i}(1:gapidxs(j),:),{outdata{i}{gapidxs(j),2},outdata{i}{gapidxs(j)+1,1},'',outdata{i}{1,4}},outdata{i}(gapidxs(j)+1:end,:));
                gapidxs(j+1:end)=gapidxs(j+1:end)+1;
           end
       end         
       
       strings{n}=sprintf('%sclass = "IntervalTier"\nname = "%s"\nxmin = %f\nxmax = %f\nintervals: size = %d\n',...
       strings{n},tiernames{i},xmin,xmax,length(outdata{i}));
       for j=1:length(outdata{i})
            strings{n}=sprintf('%sintervals [%d]:\nxmin = %f\nxmax = %f\ntext = "%s"\n',... 
            strings{n},j,outdata{i}{j,1},outdata{i}{j,2},outdata{i}{j,3})
        end
   end
end
fid=fopen(outpath,'w')
for i=1:length(strings)
   fprintf(fid,'%s',strings{i}) 
end
fclose(fid)