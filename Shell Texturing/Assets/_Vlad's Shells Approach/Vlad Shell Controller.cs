using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VladShellController : MonoBehaviour
{
    public bool UpdateVariables = true;
    public bool GlobalShellDirection = true;
    public bool TapperShells = true;

    [Header("Shells and Fins Components")]
    public Shader shellShader;
    public Shader finsShader;
    public Texture2D shellTexture;
    public Texture2D shellsLocationTexture;
    public Color tint;
    public Texture2D finsTexture;

    [Header("Shells and Fins Variables")]
    [Range(1.0f, 1000.0f)]
    public float density = 150.0f;
    [Range(0.0f, 3.0f)]
    public float maxShellLenght = 0.2f;
    [Range(0.0f, 1.0f)]
    public float noiseMin = 0.0f;
    [Range(0.0f, 1.0f)]
    public float noiseMax = 1.0f;

    [Header("Shells Variables")]
    [Range(0, 128)]
    public int shellCount = 32;
    [Range(0.0f, 1.5f)]
    public float thickness = 1.0f;
    [Range(0.01f, 3.0f)]
    public float distanceAttenuation = 1.0f;
    [Range(1.0f, 10.0f)]
    public float curvature = 3.0f;

    public Vector3 shellDirection;

    private Material shellMaterial;
    private List<GameObject> shells;
    private Material finsMaterial;
    private GameObject fins;
    private void OnEnable()
    {
        shellMaterial = new Material(shellShader);
        shells = new List<GameObject>();
        GameObject shellHolder = new GameObject("Shell Holder");
        shellHolder.transform.SetParent(this.transform, false);

        for (int i = 0; i < shellCount; i++)
        {
            shells.Add(new GameObject("Shell " + i.ToString()));
            shells[i].AddComponent<MeshFilter>();
            shells[i].AddComponent<MeshRenderer>();

            shells[i].GetComponent<MeshFilter>().mesh = this.GetComponent<MeshFilter>().mesh;
            shells[i].GetComponent<MeshRenderer>().material = shellMaterial;
            shells[i].transform.SetParent(shellHolder.transform, false);

            UpdateShellVariables(i);
        }

        finsMaterial = new Material(finsShader);
        GameObject finsHolder = new GameObject("Fins Holder");
        finsHolder.transform.SetParent(this.transform, false);

        fins = new GameObject("Fins");
        fins.AddComponent<MeshFilter>();
        fins.AddComponent<MeshRenderer>();

        fins.GetComponent<MeshFilter>().mesh = this.GetComponent<MeshFilter>().mesh;
        fins.GetComponent<MeshRenderer>().material = finsMaterial;
        fins.transform.SetParent(finsHolder.transform, false);

        UpdateFinsVariables();
    }

    private void FixedUpdate()
    {
        if (UpdateVariables)
        {
            for (int i = 0; i < shellCount; i++)
            {
                UpdateShellVariables(i);
            }

            UpdateFinsVariables();
        }
    }

    void UpdateShellVariables(int _index)
    {
        SetKeyword(_index, "_GLOBAL_SHELL_DIRECTION", GlobalShellDirection);
        SetKeyword(_index, "_TAPPER_SHELLS", TapperShells);

        if (shellTexture)
        {
            shells[_index].GetComponent<MeshRenderer>().material.SetTexture("_ShellTexture", shellTexture);
        }
        else
        {
            shells[_index].GetComponent<MeshRenderer>().material.SetTexture("_ShellTexture", Texture2D.whiteTexture);
        }
        if (shellsLocationTexture)
        {
            shells[_index].GetComponent<MeshRenderer>().material.SetTexture("_ShellsLocationTexture", shellsLocationTexture);
        }
        else
        {
            shells[_index].GetComponent<MeshRenderer>().material.SetTexture("_ShellsLocationTexture", Texture2D.whiteTexture);
        }
        shells[_index].GetComponent<MeshRenderer>().material.SetColor("_Tint", tint);

        shells[_index].GetComponent<MeshRenderer>().material.SetInt("_ShellIndex", _index);
        shells[_index].GetComponent<MeshRenderer>().material.SetInt("_ShellCount", shellCount);

        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_Density", density);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_MaxShellLength", maxShellLenght);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_NoiseMin", noiseMin);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_NoiseMax", noiseMax);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_Thickness", thickness);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_Curvature", curvature);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_ShellDistanceAttenuation", distanceAttenuation);

        shells[_index].GetComponent<MeshRenderer>().material.SetVector("_ShellDirection", shellDirection);
    }
    void UpdateFinsVariables()
    {
        if (shellTexture)
        {
            fins.GetComponent<MeshRenderer>().material.SetTexture("_ShellTexture", shellTexture);
        }
        else
        {
            fins.GetComponent<MeshRenderer>().material.SetTexture("_ShellTexture", Texture2D.whiteTexture);
        }
        if (shellsLocationTexture)
        {
            fins.GetComponent<MeshRenderer>().material.SetTexture("_ShellsLocationTexture", shellsLocationTexture);
        }
        else
        {
            fins.GetComponent<MeshRenderer>().material.SetTexture("_ShellsLocationTexture", Texture2D.whiteTexture);
        }
        fins.GetComponent<MeshRenderer>().material.SetColor("_Tint", tint);
        if (finsTexture)
        {
            fins.GetComponent<MeshRenderer>().material.SetTexture("_FinsTexture", finsTexture);
        }
        else
        {
            fins.GetComponent<MeshRenderer>().material.SetTexture("_FinsTexture", Texture2D.blackTexture);
        }

        fins.GetComponent<MeshRenderer>().material.SetFloat("_Density", density);
        fins.GetComponent<MeshRenderer>().material.SetFloat("_MaxShellLength", maxShellLenght);
        fins.GetComponent<MeshRenderer>().material.SetFloat("_NoiseMin", noiseMin);
        fins.GetComponent<MeshRenderer>().material.SetFloat("_NoiseMax", noiseMax);
    }
    void SetKeyword(int _index, string _keyword, bool _state)
    {
        if (_state)
        {
            shells[_index].GetComponent<MeshRenderer>().material.EnableKeyword(_keyword);
        }
        else
        {
            shells[_index].GetComponent<MeshRenderer>().material.DisableKeyword(_keyword);
        }
    }

    void OnDisable()
    {
        for (int i = 0; i < shells.Count; ++i)
        {
            Destroy(shells[i]);
        }
        shells.Clear();

        Destroy(fins);
    }
}
