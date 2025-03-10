using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShellController : MonoBehaviour
{
    public bool UpdateVariables = true;

    [Header("Shell Components")]
    public Shader shellShader;
    public Color mainColor = new Color(0.18f, 0.56f, 0);

    [Header("Shell Variables")]
    [Range(0, 128)]
    public int shellCount = 16;
    [Range(0.0f, 1.0f)]
    public float shellLenght = 0.15f;
    [Range(1.0f, 1000.0f)]
    public float density = 100.0f;
    [Range(0.0f, 1.0f)]
    public float noiseMin = 0.0f;
    [Range(0.0f, 1.0f)]
    public float noiseMax = 1.0f;
    [Range(0.0f, 1.5f)]
    public float thickness = 1.0f;
    [Range(0.0f, 5.0f)]
    public float occlusionAttenuation = 1.0f;
    [Range(0.0f, 1.0f)]
    public float occlusionBias = 0.0f;
    [Range(0.01f, 3.0f)]
    public float distanceAttenuation = 1.0f;

    private Material shellMaterial;
    private List<GameObject> shells;
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

            UpdateShaderVariables(i);
        }
    }

    private void FixedUpdate()
    {
        if(UpdateVariables)
        {
            for (int i = 0; i < shellCount; i++)
            {
                UpdateShaderVariables(i);
            }
        }
    }

    void UpdateShaderVariables(int _index)
    {
        shells[_index].GetComponent<MeshRenderer>().material.SetColor("_MainColor", mainColor);

        shells[_index].GetComponent<MeshRenderer>().material.SetInt("_ShellIndex", _index);
        shells[_index].GetComponent<MeshRenderer>().material.SetInt("_ShellCount", shellCount);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_ShellLength", shellLenght);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_Density", density);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_NoiseMin", noiseMin);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_NoiseMax", noiseMax);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_Thickness", thickness);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_Attenuation", occlusionAttenuation);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_OcclusionBias", occlusionBias);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_ShellDistanceAttenuation", distanceAttenuation);
    }

    void OnDisable()
    {
        for (int i = 0; i < shells.Count; ++i)
        {
            Destroy(shells[i]);
        }
        shells.Clear();
    }
}
