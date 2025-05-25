using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VladShellController : MonoBehaviour
{
    public bool UpdateVariables = true;
    public bool GlobalShellDirection = true;
    public bool ShowShells = true;
    public bool ShowFins = true;

    [Header("Components")]
    public Shader shellShader;
    public Shader finsShader;
    public Texture2D shellTexture;
    public Texture2D shellsLocationTexture;
    public Color tint = Color.white;
    public Texture2D finsTexture;

    [Header("Common Variables")]
    [Range(1.0f, 1000.0f)]
    public float density = 1000.0f;
    [Range(0.0f, 3.0f)]
    public float maxShellLenght = 0.1f;
    [Range(0.0f, 1.0f)]
    public float noiseMin = 0.3f;
    [Range(0.0f, 1.0f)]
    public float noiseMax = 1.0f;
    [Range(0.0f, 5.0f)]
    public float occlusionAttenuation = 1.25f;
    [Range(0.0f, 1.0f)]
    public float occlusionBias = 0.8f;
    public Vector3 direction = new Vector3(0, -0.07f, 0);

    [Header("Shells Variables")]
    [Tooltip("If true shells will be round. If false they will be blocky")]
    public bool TapperShells = true;
    [Range(0, 128)]
    public int shellCount = 32;
    [Range(0.0f, 1.5f)]
    public float thickness = 1.0f;
    [Range(1.0f, 10.0f)]
    public float curvature = 2.0f;
    [Range(0.01f, 3.0f)]
    public float distanceAttenuation = 1.25f;

    [Header("Fins Variables")]
    [Tooltip("Controlls how we detect shells. If true it will use camera direction. If false will use camera position in relation vertex")]
    public bool UseCameraDir = true;
    [Range(0.0f, 1.0f)]
    public float lenghtOffset = 0.05f;
    [Range(0.0f, 1.0f)]
    public float directionPower = 0.2f;
    [Range(0.0f, 1.0f)]
    public float maxCameraOffset = 0.4f;

    private Material shellMaterial;
    private List<GameObject> shells;
    private Material finsMaterial;
    private GameObject fins;
    private void OnEnable()
    {
        Mesh mesh;
        if (this.GetComponent<MeshFilter>() != null)
        {
            MeshRenderer renderer = this.GetComponent<MeshRenderer>();
            mesh = this.GetComponent<MeshFilter>().mesh;
            //renderer.enabled = false;
        }
        else
        {
            SkinnedMeshRenderer renderer = this.GetComponent<SkinnedMeshRenderer>();
            mesh = renderer.sharedMesh;
            //renderer.enabled = false;
        }

        shellMaterial = new Material(shellShader);
        shells = new List<GameObject>();
        GameObject shellHolder = new GameObject("Shell Holder");
        shellHolder.transform.SetParent(this.transform, false);

        for (int i = 0; i < shellCount; i++)
        {
            shells.Add(new GameObject("Shell " + i.ToString()));
            shells[i].AddComponent<MeshFilter>();
            shells[i].AddComponent<MeshRenderer>();

            shells[i].GetComponent<MeshFilter>().mesh = mesh;
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

        fins.GetComponent<MeshFilter>().mesh = mesh;
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
                shells[i].SetActive(ShowShells);
                UpdateShellVariables(i);
            }

            fins.SetActive(ShowFins);
            UpdateFinsVariables();

        }
    }

    void UpdateShellVariables(int _index)
    {
        SetKeyword(shells[_index], "_GLOBAL_SHELL_DIRECTION", GlobalShellDirection);
        SetKeyword(shells[_index], "_TAPPER_SHELLS", TapperShells);

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
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_Attenuation", occlusionAttenuation);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_OcclusionBias", occlusionBias);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_ShellDistanceAttenuation", distanceAttenuation);

        shells[_index].GetComponent<MeshRenderer>().material.SetVector("_ShellDirection", direction);
    }
    void UpdateFinsVariables()
    {
        SetKeyword(fins, "_USE_CAMERA_DIR", UseCameraDir);

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
        fins.GetComponent<MeshRenderer>().material.SetFloat("_Attenuation", occlusionAttenuation);
        fins.GetComponent<MeshRenderer>().material.SetFloat("_OcclusionBias", occlusionBias);

        fins.GetComponent<MeshRenderer>().material.SetVector("_ShellDirection", direction);

        fins.GetComponent<MeshRenderer>().material.SetFloat("_LenghtOffset", lenghtOffset);
        fins.GetComponent<MeshRenderer>().material.SetFloat("_DirectionPower", directionPower);
        fins.GetComponent<MeshRenderer>().material.SetFloat("_MaxOffset", maxCameraOffset);
    }
    void SetKeyword(GameObject _layer, string _keyword, bool _state)
    {
        if (_state)
        {
            _layer.GetComponent<MeshRenderer>().material.EnableKeyword(_keyword);
        }
        else
        {
            _layer.GetComponent<MeshRenderer>().material.DisableKeyword(_keyword);
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
