package faxe.model;

import nme.Assets;
import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.geom.ColorTransform;

import faxe.Main;
import jarnik.gaxe.Debug;

enum ALIGN_H {
    ALIGN_H_NONE;
    ALIGN_H_LEFT;
    ALIGN_H_RIGHT;
    ALIGN_H_CENTER;
    ALIGN_H_STRETCH;
}

enum ALIGN_V {
    ALIGN_V_NONE;
    ALIGN_V_TOP;
    ALIGN_V_BOTTOM;
    ALIGN_V_CENTER;
    ALIGN_V_STRETCH;
}

typedef AlignConfig = {
    h:ALIGN_H,
    v:ALIGN_V
}

class ElementSprite extends Sprite
{

    public var marginLeft:Float;
    public var marginRight:Float;
    public var marginTop:Float;
    public var marginBottom:Float;
    public var alignment:AlignConfig;
    public var wrapperWidth:Float;
    public var wrapperHeight:Float;

    public var isContentNode:Bool;
    public var content:ElementSprite;

	public function new ( isContentNode:Bool = true ) 
	{
        super();
        
        marginLeft = 0;
        marginRight = 0;
        marginTop = 0;
        marginBottom = 0;

        this.isContentNode = isContentNode;
        alignment = { h: ALIGN_H_NONE, v: ALIGN_V_NONE };
	}

    public function align( r:Rectangle = null ):Void {
        if ( isContentNode ) {
            r.x -= x;
            r.y -= y;
            Debug.log(name+" aligning kids to "+r);
            for ( i in 0...numChildren ) {
                if ( Std.is( getChildAt( i ), ElementSprite ) )
                    cast( getChildAt( i ), ElementSprite ).align( r.clone() );
            }
        } else {
            Debug.log(name+" align CFG "+alignment);

            switch ( alignment.h ) {
                case ALIGN_H_LEFT:
                    x = r.x;
                case ALIGN_H_RIGHT:
                    x = r.x + r.width - wrapperWidth;
                case ALIGN_H_CENTER:
                    x = r.x + (r.width - wrapperWidth) / 2;
                default:                    
            }
            Debug.log(name+" aligning myself to "+x+" within "+r);

            //r = getBounds( parent );
            r.x = 0; r.y = 0;
            r.width = Math.isNaN( wrapperWidth ) ? r.width : wrapperWidth;
            r.height = Math.isNaN( wrapperHeight ) ? r.height : wrapperHeight;
            Debug.log(name+" sending to content area "+r);
            content.align( r );
        }
    }
    
    public function addContent( _content:ElementSprite, allowResetOrigin:Bool = true ):Void {
        content = _content;
        addChild( content );

        if ( allowResetOrigin )
            resetOrigin();
    }
   
    private function resetOrigin():Void {
        Debug.log(" resetting origin for content "+content.name+" within wrapper ");
        Debug.log(" ... content x "+content.x+" rot "+content.rotation);
        var r:Rectangle = content.getBounds( this );
        Debug.log(" ... bounds of content within wrapper "+r);

        x = r.x;
        y = r.y;
        content.x -= r.x;
        content.y -= r.y;

        wrapperWidth = r.width;
        wrapperHeight = r.height;

        Debug.log(" ... wrapper within ist parent will be "+x+" "+y);
        Debug.log(" ... content within wrapper will be "+content.x+" "+content.y);
    }

}
