"""휘팍 개장빵 배너 생성 — ski_slope_scene_web.dart / ski_slope_actors_web.dart 포팅."""
import math
from PIL import Image, ImageDraw, ImageFont

SNOW=(0xF5,0xF9,0xFD); SH1=(0xE6,0xF0,0xF8); SH2=(0xCC,0xDF,0xEE); SH3=(0xAC,0xC7,0xDE)
PINE=(0x2C,0x4C,0x50); PINEDARK=(0x1A,0x33,0x37); PINESNOW=(0xE9,0xF3,0xFD)
TRACK=(0xD2,0xE0,0xEE); STRUCT=(0x33,0x50,0x6B); STRUCTDARK=(0x22,0x37,0x4A)
WINDOW=(0xF0,0xC6,0x69); NIGHT=(0x1F,0x3B,0x42); DEEPBLUE=(0x3D,0x66,0x83)
BLUE=(0x3D,0x83,0xED); BLUE700=(0x2B,0x5D,0xA8); WHITE=(0xFF,0xFF,0xFF)
SILHOUETTE=(0x2B,0x47,0x52); SKIDARK=(0x1A,0x33,0x37)
ACCENTS=[(0xD4,0x63,0x5A),(0xD9,0xA2,0x4B),(0x5F,0xA8,0x82),
         (0x3E,0x9A,0xA3),(0x5E,0x6F,0xB8),(0xA8,0x5B,0x92)]

M31=0x7FFFFFFF
def _hash(x,y,seed):
    h=((x*73856093)^(y*19349663)^(seed*83492791))&M31
    h^=h>>15; h=(h^((h<<13)&M31))&M31; h^=h>>7
    h=(h^((h<<9)&M31))&M31; h^=h>>11
    return h&M31
def h01(x,y,s): return _hash(x,y,s)/M31
def _sm(t): return t*t*(3-2*t)
def noise(x,y,s):
    xi=math.floor(x); yi=math.floor(y); xf=_sm(x-xi); yf=_sm(y-yi)
    a=h01(xi,yi,s); b=h01(xi+1,yi,s); c=h01(xi,yi+1,s); d=h01(xi+1,yi+1,s)
    return (a+(b-a)*xf)*(1-yf)+(c+(d-c)*xf)*yf
def fbm(x,y,s):
    return noise(x,y,s)*0.6+noise(x*2.1,y*2.1,s+7)*0.3+noise(x*4.3,y*4.3,s+13)*0.1

class Geo:
    def __init__(self, cols, pisteFrac=0.336):
        self.cols=cols
        self.halfBase=min(cols*pisteFrac, cols*0.40)
        self.sway=min(cols*0.03, 16.0)
    def center(self,y):  # y = 행(셀)
        return self.cols/2 + self.sway*(math.sin(y*0.0085)*0.62+math.sin(y*0.0033+1.1)*0.38)
    def half(self,y):    return self.halfBase*(1+0.10*math.sin(y*0.0050+0.6))
    def cable(self,y):   return self.center(y)+self.half(y)*0.92

class Buf:
    def __init__(self,w,h):
        self.w=w; self.h=h; self.px=[SNOW]*(w*h)
    def set(self,x,y,c):
        if 0<=x<self.w and 0<=y<self.h: self.px[y*self.w+x]=c
    def span(self,y,l,r,c):
        for x in range(l,r+1): self.set(x,y,c)

def pine(buf,cx,by,h):
    half=max(1,round(h*0.30)); sl=round(h*1.6)
    for k in range(sl):
        t=k/max(1,sl); sx=cx-round(k*1.25)-1; sy=by+round(k*0.16)
        w=max(0,round(half*(1-t*0.85)))
        buf.span(sy,sx-w,sx+w, SH2 if t<0.45 else SH1)
    for k in range(h):
        t=k/max(1,h-1); tier=k/2.6; step=tier-math.floor(tier)
        w=round(0.3+half*t*(0.80+0.30*step))
        for d in range(-w,w+1):
            buf.set(cx+d, by-h+k, PINEDARK if d>w*0.3 else PINE)
        if step<1/2.6 and w>=1:
            capw=max(1,round(w*0.55))
            for d in range(-w,-w+capw): buf.set(cx+d,by-h+k,PINESNOW)
    buf.set(cx,by-h,PINESNOW)
    for k in range(max(1,round(h*0.10))): buf.set(cx,by-k,PINEDARK)

class Clear:
    FE=0.45
    def __init__(self,cx,cy,hx,hy): self.cx,self.cy,self.hx,self.hy=cx,cy,hx,hy
    def f(self,px,py):
        d=math.hypot((px-self.cx)/self.hx,(py-self.cy)/self.hy)
        if d>=1+self.FE: return 1.0
        if d<=1: return 0.0
        return (d-1)/self.FE

def forest(buf,geo,cols,rows,clear):
    clumps=[]; count=max(6,round(rows/130))
    for i in range(count):
        r1=h01(i,0,991); r2=h01(i,1,991); r3=h01(i,2,991)
        side=-1 if i%2==0 else 1
        clumps.append((cols/2+side*(cols*0.22+r1*cols*0.26), r2*rows*1.05, 26+r3*40))
    gx,gy=11,10; cy=-1
    while cy*gy<rows+40:
        cxi=-1
        while cxi*gx<cols+30:
            px=cxi*gx+math.floor(h01(cxi,cy,101)*gx); py=cy*gy+math.floor(h01(cxi,cy,151)*gy)
            best=min(math.hypot(px-c[0],py-c[1])/c[2] for c in clumps)
            if best<=1.15:
                k=clear.f(px,py) if clear else 1.0
                if k>0 and h01(cxi,cy,211)<=(1-best/1.15)*0.85*k:
                    pine(buf,px,py,round((8+h01(cxi,cy,307)*14)*(0.45+0.55*k)))
            cxi+=1
        cy+=1
    stray(buf,geo,cols,rows,clear)

def stray(buf,geo,cols,rows,clear):
    gx,gy=40,36; cy=0
    while cy*gy<rows:
        cxi=0
        while cxi*gx<cols:
            if h01(cxi,cy,613)<=0.26:
                px=cxi*gx+math.floor(h01(cxi,cy,617)*gx); py=cy*gy+math.floor(h01(cxi,cy,619)*gy)
                if py<rows:
                    d=abs(px-geo.center(py))/geo.half(py)
                    if d>=0.55:
                        k=clear.f(px,py) if clear else 1.0
                        if k>0 and h01(cxi,cy,631)<=k:
                            pine(buf,px,py,round((7+h01(cxi,cy,623)*8)*(0.45+0.55*k)))
            cxi+=1
        cy+=1

def shrubs(buf,cols,rows):
    n=max(8,round(rows/40))
    for i in range(n):
        x=math.floor(h01(i,5,771)*cols); y=math.floor(h01(i,6,771)*rows)
        if abs(x-cols/2)<cols*0.08: continue
        for dx,dy in((0,0),(-1,-1),(1,-1),(0,-1),(0,-2),(-2,0),(2,0)): buf.set(x+dx,y+dy,PINEDARK)
        buf.span(y+1,x-4,x+1,SH1)

def lift(buf,geo,rows):
    for y in range(rows): buf.set(round(geo.cable(y)),y,STRUCT)
    y=40
    while y<rows:
        lx=round(geo.cable(y)); buf.span(y,lx-3,lx+3,STRUCTDARK)
        for k in range(1,5): buf.set(lx,y+k,STRUCTDARK)
        buf.span(y+5,lx-6,lx-1,SH2); y+=150

def lodge(buf,geo,rows):
    if rows<60: return
    cx=round(geo.center(6)); top=5
    for k in range(7): buf.span(top+8+k,cx-14-k,cx+11-k,SH2)
    for k in range(5): buf.span(top+k,cx-2-k*2,cx+2+k*2,STRUCTDARK)
    for k in range(4): buf.span(top+5+k,cx-10,cx+10,STRUCT)
    for a,b in((-7,-5),(-1,1),(5,7)): buf.span(top+6,cx+a,cx+b,WINDOW)
    buf.span(top+9,cx-10,cx+10,STRUCTDARK)
    for x in range(cx-8,cx+9,4):
        buf.set(x,top+10,STRUCTDARK); buf.set(x,top+11,STRUCTDARK)

RIDER=['..ooo..','..ooo..','.orrro.','orrrrro','.orrro.','.orrro.','.oo.oo.','.o...o.','kkkkkkk','.......']
CHAIR=['...oo..','...oo..','.oooooo','o.o..o.','orooro.','oooooo.','oooooo.','.o..o..','.k..k..','.......']

def sprite(buf,grid,cx,cy,accent):
    leg={'o':SILHOUETTE,'k':SKIDARK,'r':accent,'i':SH2,'n':NIGHT}
    h=len(grid); w=len(grid[0])
    for y in range(h):
        for x in range(w):
            ch=grid[y][x]
            if ch in leg: buf.set(cx-w//2+x, cy-h//2+y, leg[ch])

def riders(buf,geo,cols,rows,n,clear=None):
    for i in range(n):
        r1=h01(i,11,457); r2=h01(i,12,457); r3=h01(i,13,457)
        lane=(-1+2*((i*2+i//2)%n+0.5)/n)*0.80
        carve=(1.0/n)*0.55*(0.6+r2*0.4); freq=0.007*3+r1*0.006*3
        ph=i/n*6.28+r3
        y=int(rows*(0.18+0.74*((i*0.37+r3)%1.0)))
        def xa(yy): return geo.center(yy)+geo.half(yy)*(lane+carve*math.sin(yy*freq+ph))
        # 글자 자리에 들어오면 통째로 건너뛴다 — 타원은 나무만 비우므로
        # 라이더·슈프르가 제목 위에 올라앉는다.
        if clear and clear.f(xa(y),y)<=0.35: continue
        for k in range(1,110):                      # 지나온 슈프르
            yy=y-k
            if yy<0: break
            for s_ in (-1,1): buf.set(round(xa(yy))+s_*1, yy, TRACK)
        sprite(buf,RIDER,round(xa(y)),y,ACCENTS[i%len(ACCENTS)])

def chairs(buf,geo,rows,n=4,clear=None):
    for i in range(n):
        y=int(rows*(0.12+0.76*i/max(1,n-1)))
        if clear and clear.f(geo.cable(y),y)<=0.35: continue
        sprite(buf,CHAIR,round(geo.cable(y)),y,ACCENTS[(i+2)%len(ACCENTS)])

def build(cols,rows,clear=None,nrid=5):
    geo=Geo(cols); buf=Buf(cols,rows)
    for y in range(rows):
        for x in range(cols):
            n=fbm(x*0.0055,y*0.0045,3)
            off=abs(x-cols/2)/(cols/2); n+=off*0.16-0.10
            c=SNOW
            if n>0.52: c=SH1
            if n>0.61: c=SH2
            if n>0.70 and off>0.55: c=SH3
            buf.px[y*cols+x]=c
    forest(buf,geo,cols,rows,clear); shrubs(buf,cols,rows)
    lift(buf,geo,rows); lodge(buf,geo,rows)
    riders(buf,geo,cols,rows,nrid,clear); chairs(buf,geo,rows,4,clear)
    im=Image.new('RGB',(cols,rows)); im.putdata(buf.px)
    return im
