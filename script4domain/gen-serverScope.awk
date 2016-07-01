function indent (d,
		i)
{
  for(i=1;i<=d*2;i++) {
		printf " "
	}

}

function jPrint(l,v,d,t,f,
		i,comma)
{
	indent(d)
	if (f==1) { comma="" } else  { comma="," }
	if (t==0) {
		printf("\"%s\": \"%s\"%s\n",l,v,comma)
	} else {
		printf("\"%s\": %s%s\n",l,v,comma)
	}
}
function subnetGen(bs,be,cs,ce,
		b,c,istart,iend,mask,scopeType,hostCount,description,depth)
{
  for (b=bs;b<=be;b++) {
        for (c=cs;c<=ce; c++) {
                istart="10."b"."c".27"
                iend=istart
                mask=32
                scopeType="subnet"
                hostCount=1
                description="description: "istart"/"mask
                indent(2)
                print "{"
                depth=3
                jPrint("scopeIpType","subnet",depth,0,0)
                jPrint("mask",mask,depth,1,0)
                jPrint("start",istart,depth,0,0)
                jPrint("end",iend,depth,0,0)
                jPrint("hostCount",hostCount,depth,1,0)
                jPrint("description",description,depth,0,1)
                indent(2)
                if (b==be && c==ce) {
                        print "}"
                } else {
                        print "},"
                }

        }
   }

}

{
	if (NF!=2) {
		print "Usage: echo \"include exclude\" | gawk -f gen-serverScope.awk"
		print "  where: include = bs,be,cs,ce - 10.B.C.27/32; start and end of B and C"
		print "         exclude = bs,be,cs,ce - 10.B.C.27/32; start and end of B and C"
		print " Example: echo \"1,2,1,2 1,2,2,3 | gawk -f gen-serverScope.awk - generates 4 includes and 4 exlcudes with 2 overlaping generating 2 calculated includes"
		exit
	}
	print "{"

	indent(1)
	print "\"include\": ["
	n=split($1,arr,",")
	subnetGen(arr[1],arr[2],arr[3],arr[4])
	indent(1)
	print "],"

	indent(1)
	print "\"exclude\": ["
	n=split($2,arr,",")
	subnetGen(arr[1],arr[2],arr[3],arr[4])
	indent(1)
	print "]"
	print "}"

}
