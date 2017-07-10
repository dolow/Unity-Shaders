using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[ExecuteInEditMode()]
public class UIMultiGradation : MonoBehaviour
{
    // gradation direction
    public enum Direction { Vertical = 0, Horizontal }

    // Gradient colors
    // It should be less than 8 colors since array length can not be defined dynamically in shader script
    public Color[] colors = null;

    // user defined gradient direction
    public Direction direction = Direction.Vertical;

    // it makes gradient image fit to masking object size
    // if subject was text, it uses preferredWidth and preferredHeight properties
    // unfortunatelly, those properties always calclulate height with base line
    [SerializeField]
    private bool autoResizeGradient = true;

    // making object for gradient image
    [SerializeField]
    private GameObject stencilMask = null;

    // gradient image object
    [SerializeField]
    private RawImage gradientImage = null;

    // user defined stencil reference id
    // use this for avoiding duplication
    [SerializeField]
    private int StencilID = 1;

    // initialize shader properties and UI elements size
    void Start()
    {
        this.RefreshProperties();

        if (this.autoResizeGradient)
        {
            this.FitToSubject();
        }
    }

    #if UNITY_EDITOR
    // updating subject's size and properties for editor convinience
    void Update()
    {
        this.RefreshProperties();

        if (this.autoResizeGradient)
            this.FitToSubject();
    }
    #endif

    // refreshing shader properties
    public void RefreshProperties()
    {
        // properties for gradation
        {
            Material mat = this.gradientImage.material;
            mat.SetInt("_ColorCount", this.colors.Length);
            mat.SetInt("_Direction", (int)this.direction);
            mat.SetInt("_StencilReference", this.StencilID);
            mat.SetColorArray("_Colors", this.colors);
        }
        // properties for subjects
        {
            Text text = this.stencilMask.GetComponentInChildren<Text>();
            if (text != null)
                text.material.SetInt("_StencilReference", this.StencilID);

            Image image = this.stencilMask.GetComponentInChildren<Image>();
            if (image != null)
                image.material.SetInt("_StencilReference", this.StencilID);
        }
    }

    // fit gradient image size to subject
    public void FitToSubject()
    {
        Text text = this.stencilMask.GetComponent<Text>();
        if (text != null) {
            this.gradientImage.rectTransform.sizeDelta = new Vector2(text.preferredWidth, text.preferredHeight);
            this.gradientImage.rectTransform.localScale = text.rectTransform.localScale;
        }

        Image image = this.stencilMask.GetComponent<Image>();
        if (image != null) {
            this.gradientImage.rectTransform.sizeDelta  = image.rectTransform.sizeDelta;
            this.gradientImage.rectTransform.localScale = image.rectTransform.localScale;
        }
    }
}
