// This class simulates a mipmap, which shrinks images by powers of two. This
// stepwise reduction results in "pixel-perfect downscaling" (where every
// pixel of the original image has some contribution to the downscaled image)
// as opposed to a single-step downscaling which will discard a lot of data
// (and with sparse images at small scales can give very surprising results).
export default class Mipmapper {
  constructor(img) {
    this._layers = [img];
  }

  // The various functions on this class take a callback function BUT MAY OR MAY
  // NOT actually behave asynchronously.
  getBySize(desiredWidth, desiredHeight, callback) {
    let i = 0;
    let lastImg = this._layers[0];
    let testNext = () => {
      this.getByIndex(i, function(img) {
        // If current image is invalid (i.e. too small to be rendered) or
        // it's smaller than what we wanted, return the last known good image.
        if (!img || img.width < desiredWidth || img.height < desiredHeight) {
          callback(lastImg);
          return;
        } else {
          lastImg = img;
          i++;
          testNext();
          return;
        }
      });
    };
    testNext();
  }

  getByIndex(i, callback) {
    if (this._layers[i]) {
      callback(this._layers[i]);
      return;
    }

    this.getByIndex(i-1, (prevImg) => {
      if (!prevImg) {
        // prevImg could not be calculated (too small, possibly)
        callback(null);
        return;
      }
      if (prevImg.width < 2 || prevImg.height < 2) {
        // Can't reduce this image any further
        callback(null);
        return;
      }
      // If reduce ever becomes truly asynchronous, we should stuff a promise or
      // something into this._layers[i] before calling this.reduce(), to prevent
      // redundant reduce operations from happening.
      this.reduce(prevImg, (reducedImg) => {
        this._layers[i] = reducedImg;
        callback(reducedImg);
        return;
      });
    });
  }

  reduce(img, callback) {
    let imgDataCanvas = document.createElement("canvas");
    imgDataCanvas.width = Math.ceil(img.width / 2);
    imgDataCanvas.height = Math.ceil(img.height / 2);
    imgDataCanvas.style.display = "none";
    document.body.appendChild(imgDataCanvas);
    try {
      let imgDataCtx = imgDataCanvas.getContext("2d");
      imgDataCtx.drawImage(img, 0, 0, img.width/2, img.height/2);
      callback(imgDataCanvas);
    } finally {
      document.body.removeChild(imgDataCanvas);
    }
  }
}
