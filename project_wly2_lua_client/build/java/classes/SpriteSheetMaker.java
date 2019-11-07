import java.awt.Graphics;
import java.awt.Rectangle;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import javax.imageio.ImageIO;


public class SpriteSheetMaker {

	/**
	 * @param args 
	 * -scale 缩放比例（默认1.0)
	 * -folder 图片目录
	 * -out 目标位置，默认folder父目录下同名文件
	 * -fileTypes 包含的文件类型，多个用逗号分开(如:.png,.jpg)，默认.png
	 * -padding 边距
	 * @throws IOException 
	 */
	public static void main(String[] args) throws IOException {
		SpriteSheetMaker maker = new SpriteSheetMaker();
		for( int i=0; i<args.length; i+=2 ) {
			if( "-scale".equals(args[i])) {
				maker._scale = Float.parseFloat(args[i+1]);
			} else if ("-folder".equals(args[i])){
				maker._folder = args[i+1];
			} else if ("-out".equals(args[i])){
				maker._out = args[i+1];
			} else if ("-fileTypes".equals(args[i])){
				maker._fileTypes = args[i+1].split(",");
			} else if ("-padding".equals(args[i])){
				maker._padding = Integer.parseInt(args[i+1]);
			}
		}
		
		maker.make();
	}
	private int _padding = 2;
	private String _plistXmlTpl;
	private String _plistItemTpl;
	private float _scale = 1.0f;
	private String _folder;
	private String _out;
	private String _plistPath;
	private String _imgPath;
	private String[] _fileTypes;
	public SpriteSheetMaker() {
		this._plistXmlTpl = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + 
							"<!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n" + 
							"<plist version=\"1.0\">\n" +
							"    <dict>\n" +
							"        <key>frames</key>\n" +
							"        <dict>\n" +
							"%frames%" +
							"        </dict>\n" +
							"        <key>metadata</key>\n" +
							"        <dict>\n" +
							"            <key>format</key>\n" +
							"            <integer>2</integer>\n" +
							"            <key>size</key>\n" +
							"            <string>{%textureSize%}</string>\n" +
							"            <key>textureFileName</key>\n" +
							"            <string>%textureName%</string>\n" +
							"        </dict>\n" +
							"    </dict>\n" +
							"</plist>";
		this._plistItemTpl= "            <key>%imgName%</key>\n" +
							"            <dict>\n" +
							"            	<key>frame</key>\n" +
							"            	<string>{{%framePos%},{%frameSize%}}</string>\n" +
							"            	<key>offset</key>\n" +
							"            	<string>{%offset%}</string>\n" +
							"            	<key>rotated</key>\n" +
							"            	<false/>\n" +
							"            	<key>sourceColorRect</key>\n" +
							"            	<string>{{%imgColorPos%},{%imgColorSize%}}</string>\n" +
							"            	<key>sourceSize</key>\n" +
							"            	<string>{%imgSize%}</string>\n" +
							"            </dict>\n";
	}
	private HashMap<String, ArrayList<File>> getAllFiles(File root, String folder) {
		HashMap<String, ArrayList<File>> map = new HashMap<String, ArrayList<File>>(); 
		map.put(folder, new ArrayList<File>());
		File[] list = new File(root, folder).listFiles();
		for( int i=0; i<list.length; i++ ) {
			if( list[i].isDirectory() ) {
				HashMap<String, ArrayList<File>> child = this.getAllFiles(root, folder + "/" + list[i].getName());
				Iterator<String> keys = child.keySet().iterator();
				while( keys.hasNext() ) {
					String key = keys.next();
					map.put( key, child.get( key ) );
				}
			} else {
				String name = list[i].getName();
				boolean allow = false;
				for( int k=0; k<this._fileTypes.length; k++ ) {
					if( name.endsWith(this._fileTypes[k]) ) {
						allow = true;
						break;
					}
				}
				if( allow ) {
					map.get(folder).add(list[i]);
				}
			}
		}
		return map;
	}
	private Rectangle getAlphaRect(BufferedImage img) throws IOException{
		Rectangle rect = new Rectangle(0,0,img.getWidth(), img.getHeight());
        // 获取图像的宽度和高度
		int trimAlpah = 2;
        int width = img.getWidth();
        int height = img.getHeight();
        boolean isTransparent = true;
        // 扫描图片
        int minY = -1;
        for (int i = 0; i < height; i++) {
        	isTransparent = true;
            for (int j = 0; j < width; j++) {// 行扫描
                long dip = img.getRGB(j, i)&0x0FFFFFFFFL;
				
                if (dip >>24 > trimAlpah ){
                	isTransparent = false;
                    break;
                }
            }
            if( isTransparent ) {
            	minY = i + 1;
            } else {
            	break;
            }
        }
        if( minY == height-1 ) {
        	//全图透明度小于2
        	return null;
        }
        int maxY = height-1;
		
        if( minY!=-1 ) {
            for (int i = height-1; i>minY; i--) {
            	isTransparent = true;
                for (int j = 0; j < width; j++) {// 行扫描
                    long dip = img.getRGB(j, i)&0x0FFFFFFFFL;
                    if (dip >>24 > trimAlpah ){
                    	isTransparent = false;
                        break;
                    }
                }
                if( isTransparent ) {
                	maxY = i - 1;
                } else {
                	break;
                }
            }
        } else {
        	minY = 0;
        }
		
        int minX = -1;
        for (int i = 0; i < width; i++) {
        	isTransparent = true;
            for (int j = minY; j <= maxY; j++) {// 列扫描
                long dip = img.getRGB(i, j)&0x0FFFFFFFFL;
                if (dip >>24 > trimAlpah ){
                	isTransparent = false;
                    break;
                }
            }
            if( isTransparent ) {
            	minX = i + 1;
            } else {
            	break;
            }
        }
        int maxX = width-1;
        if( minX!=-1 ) {
	        for (int i = width-1; i>minX; i--) {
	        	isTransparent = true;
	            for (int j = minY; j <= maxY; j++) {// 列扫描
	                long dip = img.getRGB(i, j)&0x0FFFFFFFFL;
	                if (dip >>24 > trimAlpah ){
	                	isTransparent = false;
	                    break;
	                }
	            }
	            if( isTransparent ) {
	            	maxX = i - 1;
	            } else {
	            	break;
	            }
	        }
        } else {
        	minX = 0;
        }

        rect.x = minX;
        rect.width = maxX - minX + 1;
        rect.y = minY;
        rect.height = maxY - minY + 1;
		
        return rect;
    }
	private void make() throws IOException {
		if( this._folder==null ) {
			System.out.println("usage:SpriteSheetMaker -folder img_folder_path [-out sheet_output_path] [-scale float]");
			return ;
		}
		File root = new File(this._folder);
		if( !root.exists() ) {
			System.out.println("folder not exists:" + this._folder);
			return ;
		}
		if( this._out==null ) {
			this._out = this._folder; 
		}
		this._plistPath = this._out + ".plist";
		this._imgPath = this._out + ".png";

		if(this._fileTypes==null) {
			this._fileTypes = new String[]{".png"};
		}

		int sumArea = 0;
		ArrayList<Rectangle> rectList = new ArrayList<Rectangle>();
		HashMap<String, ArrayList<BufferedImage>> imgMap = new HashMap<String, ArrayList<BufferedImage>>(); 
		HashMap<String, ArrayList<Rectangle>> imgSizeMap = new HashMap<String, ArrayList<Rectangle>>(); 
		HashMap<String, ArrayList<String>> imgNameMap = new HashMap<String, ArrayList<String>>(); 
		HashMap<String, ArrayList<Rectangle>> imgAlphaRectMap = new HashMap<String, ArrayList<Rectangle>>(); 
		HashMap<String, ArrayList<File>> fileList = this.getAllFiles( root.getParentFile(), root.getName() );
		Iterator<String> keys = fileList.keySet().iterator();
		while( keys.hasNext() ) {
			String key = keys.next();
			ArrayList<File> imgList = fileList.get(key);
			for( int i=0; i<imgList.size(); i++ ) {
				BufferedImage img = ImageIO.read(imgList.get(i));

				if( this._scale!=1.0f ) {
					int w = (int)(img.getWidth()*this._scale);
					int h = (int)(img.getHeight()*this._scale);
					
					BufferedImage bid = new BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB);
					Graphics g = bid.getGraphics();
					g.drawImage(img.getScaledInstance(w, h,  BufferedImage.SCALE_SMOOTH), 0, 0,null);
					img = bid;
				}
				
				Rectangle r = this.getAlphaRect(img);
				Rectangle size = new Rectangle(0,0, img.getWidth(), img.getHeight());
				
				if( r!=null && r.width>0 && r.height>0 ) {
					BufferedImage bid = new BufferedImage(r.width, r.height, BufferedImage.TYPE_INT_ARGB);
					Graphics g = bid.getGraphics();
					g.drawImage(img, 0, 0, r.width, r.height, r.x, r.y, r.x + r.width, r.y + r.height, null);
					img = bid;
				}
				
				rectList.add(new Rectangle(0,0,img.getWidth()+_padding*2, img.getHeight()+_padding*2));
				
				String imgKey = (int)img.getWidth()+ "," + (int)img.getHeight();
				if( !imgMap.containsKey(imgKey) ) {
					imgMap.put(imgKey, new ArrayList<BufferedImage>());
				}
				imgMap.get(imgKey).add(img);

				if( !imgNameMap.containsKey(imgKey) ) {
					imgNameMap.put(imgKey, new ArrayList<String>());
				}
				key = key.split("/")[0];
				imgNameMap.get(imgKey).add(key + "/" + imgList.get(i).getName());

				if( !imgAlphaRectMap.containsKey(imgKey) ) {
					imgAlphaRectMap.put(imgKey, new ArrayList<Rectangle>());
				}
				imgAlphaRectMap.get(imgKey).add(r);

				if( !imgSizeMap.containsKey(imgKey) ) {
					imgSizeMap.put(imgKey, new ArrayList<Rectangle>());
				}
				imgSizeMap.get(imgKey).add(size);
				
				sumArea += (int)img.getWidth() * (int)img.getHeight();
			}
		}
		

		int num = (int)Math.sqrt(sumArea);
		num = pow2n(num)-1;
		double fitw = Math.pow(2, num);
		double fith = Math.pow(2, num);
		int flag = 1;
		boolean found = false;
		Rectangle tmp;
		while( true ) {
			found = true;
			MaxRectsBinPack rects = new MaxRectsBinPack((int)fitw, (int)fith, false);
			for( int i=0; i<rectList.size(); i++ ) {
				tmp = rectList.get(i);
				tmp = rects.insert((int)tmp.getWidth(), (int)tmp.getHeight(), MaxRectsBinPack.BestAreaFit);
				if( tmp.width==0 || tmp.height==0 ) {
					found = false;
					break;
				}
			}
			if( found ) {
				break;
			}
			if( flag==1 ) {
				fitw = Math.pow(2, num++);
				flag = 2;
			} else {
				flag = 1;
				fith = Math.pow(2, num);
			}
		}
		MaxRectsBinPack maxRects = new MaxRectsBinPack((int)fitw, (int)fith, false);
		maxRects.insert2(rectList, MaxRectsBinPack.BestAreaFit);
		
		int len = maxRects.usedRectangles.size();

		int w=0;
		int h=0;
		for (int i = 0; i < len; i++) {
			Rectangle rect = maxRects.usedRectangles.get(i);
			w = Math.max(w, rect.x+rect.width);
			h = Math.max(h, rect.y+rect.height);
		}
		//w = (int)Math.pow(2, pow2n(w));
		//h = (int)Math.pow(2, pow2n(h));
		BufferedImage bout = new BufferedImage(w, h,BufferedImage.TYPE_INT_ARGB);
		/*ImageObserver obser = new ImageObserver() {
			
			@Override
			public boolean imageUpdate(Image img, int infoflags, int x, int y,
					int width, int height) {
				return true;
			}
	    };*/
	    
		Graphics g = bout.getGraphics();
		String plistFrame = "";
		for (int i = 0; i < len; i++) {
			Rectangle rect = maxRects.usedRectangles.get(i);
			String imgKey = (rect.width-_padding*2)+ "," + (rect.height-_padding*2);
			BufferedImage oriImg = imgMap.get(imgKey).get(0);
			Rectangle alphaRect = imgAlphaRectMap.get(imgKey).get(0);
			if(alphaRect==null) {
				alphaRect = new Rectangle(0,0,rect.width-_padding*2,rect.height-_padding*2);
			}
			Rectangle size = imgSizeMap.get(imgKey).get(0);
			
			int offsetX = alphaRect.width > 0 ? alphaRect.width/2+alphaRect.x - size.width/2 : 0;
			int offsetY = alphaRect.height>0 ? size.height/2 - (alphaRect.height/2+alphaRect.y) : 0;
			
			plistFrame += this._plistItemTpl.replace("%imgName%", imgNameMap.get(imgKey).get(0))
											  .replace("%framePos%", (rect.x+_padding)+ "," + (rect.y+_padding))
											  .replace("%frameSize%", imgKey)
											  .replace("%offset%", offsetX + "," + offsetY)
											  .replace("%imgColorPos%", alphaRect.x + "," + alphaRect.y)
											  .replace("%imgColorSize%", alphaRect.width + "," + alphaRect.height)
											  .replace("%imgSize%", size.width + "," + size.height);
			imgMap.get(imgKey).remove(0);
			imgNameMap.get(imgKey).remove(0);
			imgAlphaRectMap.get(imgKey).remove(0);
			imgSizeMap.get(imgKey).remove(0);
		    g.drawImage(oriImg, rect.x+_padding, rect.y+_padding, rect.width-_padding*2, rect.height-_padding*2, null);
		}
		File imgFile = new File(this._imgPath);
		ImageIO.write(bout, "png", imgFile);
		
		String plist = this._plistXmlTpl.replace("%textureSize%", bout.getWidth() + "," + bout.getHeight()) 
										.replace("%textureName%", imgFile.getName())
										.replace("%frames%", plistFrame);
		FileWriter fw = new FileWriter(this._plistPath);
		fw.write(plist);
		fw.flush();
		fw.close();
		System.out.println("[output]" + this._imgPath);
	}
	private int pow2n( int num ) {
		return Integer.toString( num, 2 ).length();		
	}
}
